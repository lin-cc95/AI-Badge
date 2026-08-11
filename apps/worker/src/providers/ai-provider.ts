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
    return (data.data ?? []).map((item, index) => ({ id: `provider-${index}`, name: `候选 ${index + 1}`, color: ['#F5A6D9', '#78E7C7', '#89DDF0'][index] ?? '#89DDF0', assetKey: item.url ?? `inline:${Boolean(item.b64_json)}` }));
  }

  async check(_input: { text?: string; assetKeys?: string[] }): Promise<{ allowed: boolean; reason?: string }> { return { allowed: true }; }
}
