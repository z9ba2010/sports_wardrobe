import { ApparelSearchResponse, VisionResponse } from '../types';

/**
 * Базовый URL сервиса «Парсер».
 * В эмуляторе Android: 'http://10.0.2.2:8000'
 * В симуляторе iOS / локальной сети: 'http://localhost:8000' или IP хоста
 */
export const PARSER_API_BASE_URL = 'http://10.0.2.2:8000';

class ParserApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = PARSER_API_BASE_URL) {
    this.baseUrl = baseUrl.replace(/\/+$/, '');
  }

  public setBaseUrl(url: string) {
    this.baseUrl = url.replace(/\/+$/, '');
  }

  /**
   * Текстовый поиск экипировки в каталоге парсера.
   * Вызывает: GET /api/v1/apparel
   */
  async searchApparel(
    query?: string,
    category?: string,
    page: number = 1,
    pageSize: number = 20
  ): Promise<ApparelSearchResponse> {
    const params = new URLSearchParams();
    if (query && query.trim()) params.append('search', query.trim());
    if (category && category.trim()) params.append('category', category.trim());
    params.append('page', String(page));
    params.append('page_size', String(pageSize));

    const url = `${this.baseUrl}/api/v1/apparel?${params.toString()}`;

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`Ошибка поиска парсера: ${response.status} ${response.statusText}`);
      }

      const data: ApparelSearchResponse = await response.json();
      return data;
    } catch (error) {
      console.warn('Parser API search failed, falling back:', error);
      throw error;
    }
  }

  /**
   * Визуальный поиск по фото с камеры телефона.
   * Вызывает: POST /api/v1/vision/recognize (multipart/form-data)
   */
  async recognizeByPhoto(
    fileUri: string,
    fileName: string = 'snapshot.jpg',
    mimeType: string = 'image/jpeg'
  ): Promise<VisionResponse> {
    const formData = new FormData();

    // В React Native объект файла передается как { uri, name, type }
    // @ts-ignore
    formData.append('file', {
      uri: fileUri,
      name: fileName,
      type: mimeType,
    });

    const url = `${this.baseUrl}/api/v1/vision/recognize`;

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
        },
        body: formData,
      });

      if (!response.ok) {
        throw new Error(`Ошибка распознавания Vision API: ${response.status}`);
      }

      const data: VisionResponse = await response.json();
      return data;
    } catch (error) {
      console.warn('Parser Vision API failed:', error);
      throw error;
    }
  }

  /**
   * Распознавание товара по внешней ссылке на изображение.
   * Вызывает: POST /api/v1/vision/recognize-url
   */
  async recognizeByUrl(imageUrl: string): Promise<VisionResponse> {
    const url = `${this.baseUrl}/api/v1/vision/recognize-url`;

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({ image_url: imageUrl }),
    });

    if (!response.ok) {
      throw new Error(`Ошибка распознавания по URL: ${response.status}`);
    }

    return await response.json();
  }
}

export const parserApi = new ParserApiClient();
