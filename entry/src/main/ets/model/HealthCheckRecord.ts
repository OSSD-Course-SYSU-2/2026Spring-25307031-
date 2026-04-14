/**
 * 健康打卡记录JSON接口
 */
export interface HealthCheckRecordJSON {
  healthStatus: '良好' | '一般' | '不适';
  note: string;
  createdAt: string;
}

/**
 * 健康打卡记录模型
 */
export class HealthCheckRecord {
  // 健康状态
  healthStatus: '良好' | '一般' | '不适';
  
  // 备注信息
  note: string;
  
  // 创建时间
  createdAt: Date;
  
  /**
   * 构造函数
   * @param healthStatus 健康状态
   * @param note 备注信息
   * @param createdAt 创建时间（可选，默认为当前时间）
   */
  constructor(healthStatus: '良好' | '一般' | '不适', note: string = '', createdAt?: Date) {
    this.healthStatus = healthStatus;
    this.note = note;
    this.createdAt = createdAt || new Date();
  }
  
  /**
   * 从JSON对象创建HealthCheckRecord实例
   * @param json JSON对象
   * @returns HealthCheckRecord实例
   */
  static fromJSON(json: HealthCheckRecordJSON): HealthCheckRecord {
    const record = new HealthCheckRecord(
      json.healthStatus,
      json.note || '',
      new Date(json.createdAt)
    );
    return record;
  }
  
  /**
   * 转换为JSON对象
   * @returns JSON对象
   */
  toJSON(): HealthCheckRecordJSON {
    return {
      healthStatus: this.healthStatus,
      note: this.note,
      createdAt: this.createdAt.toISOString()
    };
  }
  
  /**
   * 获取格式化日期时间
   * @returns 格式化的日期时间字符串
   */
  getFormattedDate(): string {
    const year = this.createdAt.getFullYear();
    const month = (this.createdAt.getMonth() + 1).toString().padStart(2, '0');
    const day = this.createdAt.getDate().toString().padStart(2, '0');
    const hours = this.createdAt.getHours().toString().padStart(2, '0');
    const minutes = this.createdAt.getMinutes().toString().padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }
  
  /**
   * 获取状态对应的图标
   * @returns 状态图标
   */
  getStatusIcon(): string {
    switch (this.healthStatus) {
      case '良好':
        return '😊';
      case '一般':
        return '😐';
      case '不适':
        return '😷';
      default:
        return '❓';
    }
  }
  
  /**
   * 获取状态对应的颜色
   * @returns 状态颜色
   */
  getStatusColor(): string {
    switch (this.healthStatus) {
      case '良好':
        return '#52c41a';
      case '一般':
        return '#faad14';
      case '不适':
        return '#f5222d';
      default:
        return '#666';
    }
  }
}