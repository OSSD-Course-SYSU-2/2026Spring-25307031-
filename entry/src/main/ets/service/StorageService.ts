import preferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

/**
 * 数据存储服务
 * 使用HarmonyOS Preferences API实现数据持久化
 */
export class StorageService {
  private static instance: StorageService;
  private preferences: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'health_check_data';
  private readonly RECORDS_KEY = 'health_records';

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }

  /**
   * 初始化存储
   */
  public async initialize(): Promise<void> {
    try {
      const context = getContext() as common.UIAbilityContext;
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);
      console.log('StorageService: Preferences initialized successfully');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`StorageService: Failed to initialize preferences: ${err.code}, ${err.message}`);
      throw err;
    }
  }

  /**
   * 保存健康记录
   * @param records 健康记录数组
   */
  public async saveHealthRecords(records: any[]): Promise<void> {
    console.log('StorageService.saveHealthRecords called with records:', records);
    if (!this.preferences) {
      console.log('Preferences not initialized, initializing...');
      await this.initialize();
    }

    try {
      const recordsJson = JSON.stringify(records);
      console.log('Saving JSON to storage:', recordsJson);
      await this.preferences!.put(this.RECORDS_KEY, recordsJson);
      await this.preferences!.flush();
      console.log('StorageService: Health records saved successfully');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`StorageService: Failed to save health records: ${err.code}, ${err.message}`);
      throw err;
    }
  }

  /**
   * 加载健康记录
   * @returns 健康记录数组
   */
  public async loadHealthRecords(): Promise<any[]> {
    console.log('StorageService.loadHealthRecords called');
    if (!this.preferences) {
      console.log('Preferences not initialized, initializing...');
      await this.initialize();
    }

    try {
      console.log('Getting records from preferences with key:', this.RECORDS_KEY);
      const recordsJson = await this.preferences!.get(this.RECORDS_KEY, '[]');
      console.log('Raw JSON from storage:', recordsJson);
      const records = JSON.parse(recordsJson as string);
      console.log('StorageService: Health records loaded successfully, count:', records.length);
      return records;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`StorageService: Failed to load health records: ${err.code}, ${err.message}`);
      return [];
    }
  }

  /**
   * 清空所有数据
   */
  public async clearAllData(): Promise<void> {
    if (!this.preferences) {
      await this.initialize();
    }

    try {
      await this.preferences!.delete(this.RECORDS_KEY);
      await this.preferences!.flush();
      console.log('StorageService: All data cleared successfully');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`StorageService: Failed to clear data: ${err.code}, ${err.message}`);
      throw err;
    }
  }

  /**
   * 获取存储统计信息
   */
  public async getStorageInfo(): Promise<{ totalRecords: number }> {
    const records = await this.loadHealthRecords();
    return {
      totalRecords: records.length
    };
  }
  
  /**
   * 通用数据保存方法
   */
  public async saveData<T>(key: string, data: T): Promise<void> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      const dataJson = JSON.stringify(data);
      await this.preferences!.put(key, dataJson);
      await this.preferences!.flush();
    } catch (error) {
      const err = error as BusinessError;
      console.error(`StorageService: Failed to save data: ${err.code}, ${err.message}`);
      throw err;
    }
  }
  
  /**
   * 通用数据加载方法
   */
  public async loadData<T>(key: string): Promise<T | null> {
    if (!this.preferences) {
      await this.initialize();
    }
    
    try {
      const dataJson = await this.preferences!.get(key, '');
      if (!dataJson) {
        return null;
      }
      return JSON.parse(dataJson as string) as T;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`StorageService: Failed to load data: ${err.code}, ${err.message}`);
      return null;
    }
  }
}