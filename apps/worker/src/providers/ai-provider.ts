export type GeneratedCandidate = { id: string; name: string; color: string; assetKey: string };

export interface ChatProvider {
  stream(input: { persona: string; messages: Array<{ role: string; content: string }> }): AsyncIterable<string>;
}

export interface ImageGenerationProvider {
  generate(input: { style: string; persona: string; tags: string[]; prompt?: string }): Promise<GeneratedCandidate[]>;
}

export interface ModerationProvider {
  check(input: { text?: string; assetKeys?: string[] }): Promise<{ allowed: boolean; reason?: string }>;
}

export class DeterministicMockProvider implements ChatProvider, ImageGenerationProvider, ModerationProvider {
  async *stream() {
    for (const chunk of ['我在呢！', '今天也一起把心情', '调成薄荷味吧。']) yield chunk;
  }

  async generate(_input: { style: string; persona: string; tags: string[]; prompt?: string }): Promise<GeneratedCandidate[]> {
    return [
      { id: 'mock-a', name: '桃桃', color: '#F5A6D9', assetKey: 'mock/mock-a.png' },
      { id: 'mock-b', name: '米露', color: '#78E7C7', assetKey: 'mock/mock-b.png' },
      { id: 'mock-c', name: '泡泡', color: '#89DDF0', assetKey: 'mock/mock-c.png' },
    ];
  }

  async check(_input: { text?: string; assetKeys?: string[] }): Promise<{ allowed: boolean; reason?: string }> { return { allowed: true }; }
}

export class ConfigurableRestProvider implements ChatProvider, ImageGenerationProvider, ModerationProvider {
  constructor(
    private readonly baseUrl: string,
    private readonly apiKey: string,
    private readonly imageModel: string,
    private readonly moderationModel: string,
    private readonly chatModel = process.env.CHAT_MODEL ?? '',
  ) {}

  async *stream(input: { persona: string; messages: Array<{ role: string; content: string }> }): AsyncIterable<string> {
    if (!this.baseUrl || !this.apiKey || !this.chatModel) throw new Error('AI_PROVIDER_NOT_CONFIGURED');
    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: { authorization: `Bearer ${this.apiKey}`, 'content-type': 'application/json' },
      body: JSON.stringify({ model: this.chatModel, stream: false, messages: [{ role: 'system', content: `请始终保持${input.persona}的人格。` }, ...input.messages] }),
    });
    if (!response.ok) throw new Error(`AI_PROVIDER_${response.status}`);
    const data = await response.json() as { choices?: Array<{ message?: { content?: string } }> };
    yield data.choices?.[0]?.message?.content ?? '';
  }

  async generate(input: { style: string; persona: string; tags: string[]; prompt?: string }): Promise<GeneratedCandidate[]> {
    if (!this.baseUrl || !this.apiKey || !this.imageModel) throw new Error('AI_PROVIDER_NOT_CONFIGURED');
    const response = await fetch(`${this.baseUrl}/images/generations`, {
      method: 'POST',
      headers: { authorization: `Bearer ${this.apiKey}`, 'content-type': 'application/json' },
      body: JSON.stringify({ model: this.imageModel, n: 3, prompt: [input.style, input.persona, ...input.tags, input.prompt].filter(Boolean).join('，') }),
    });
    if (!response.ok) throw new Error(`AI_PROVIDER_${response.status}`);
    const data = await response.json() as { data?: Array<{ url?: string; b64_json?: string }> };
    return (data.data ?? []).map((item, index) => {
      if (!item.url) throw new Error('AI_PROVIDER_IMAGE_URL_REQUIRED_FOR_MODERATION');
      return {
        id: `provider-${index}`,
        name: `候选 ${index + 1}`,
        color: ['#F5A6D9', '#78E7C7', '#89DDF0'][index] ?? '#89DDF0',
        assetKey: item.url,
      };
    });
  }

  async check(input: { text?: string; assetKeys?: string[] }): Promise<{ allowed: boolean; reason?: string }> {
    if (!this.baseUrl || !this.apiKey || !this.moderationModel) {
      throw new Error('AI_MODERATION_NOT_CONFIGURED');
    }

    const moderationInput: Array<Record<string, unknown>> = [];
    if (input.text?.trim()) moderationInput.push({ type: 'text', text: input.text.trim() });
    for (const assetKey of input.assetKeys ?? []) {
      if (!/^https:\/\//i.test(assetKey)) {
        return { allowed: false, reason: 'UNSUPPORTED_ASSET_FOR_MODERATION' };
      }
      moderationInput.push({ type: 'image_url', image_url: { url: assetKey } });
    }
    if (moderationInput.length === 0) return { allowed: false, reason: 'EMPTY_MODERATION_INPUT' };

    const response = await fetch(`${this.baseUrl}/moderations`, {
      method: 'POST',
      headers: { authorization: `Bearer ${this.apiKey}`, 'content-type': 'application/json' },
      body: JSON.stringify({ model: this.moderationModel, input: moderationInput }),
    });
    if (!response.ok) throw new Error(`AI_MODERATION_PROVIDER_${response.status}`);
    const data = await response.json() as {
      results?: Array<{ flagged?: boolean; categories?: Record<string, boolean> }>;
    };
    const result = data.results?.[0];
    if (typeof result?.flagged !== 'boolean') throw new Error('AI_MODERATION_INVALID_RESPONSE');
    const categories = Object.entries(result.categories ?? {})
      .filter(([, flagged]) => flagged)
      .map(([category]) => category);
    return {
      allowed: !result.flagged,
      reason: result.flagged ? categories.join(',') || 'FLAGGED_BY_PROVIDER' : undefined,
    };
  }
}
