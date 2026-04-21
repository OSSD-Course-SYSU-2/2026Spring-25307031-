/**
 * 用药记录JSON接口
 */
export interface MedicationRecordJSON {
  medicineName: string;
  dosage: string;
  time: string;
  isTaken: boolean;
  createdAt: string;
  reminderId?: number; // 提醒ID
  frequency?: string; // 服药频率
  notes?: string; // 备注
}

/**
 * 用药记录模型
 */
export class MedicationRecord {
  medicineName: string;
  dosage: string;
  time: string;
  isTaken: boolean;
  createdAt: Date;
  reminderId?: number;
  frequency: string;
  notes: string;

  constructor(
    medicineName: string,
    dosage: string,
    time: string,
    isTaken: boolean = false,
    createdAt?: Date,
    reminderId?: number,
    frequency: string = '每天',
    notes: string = ''
  ) {
    this.medicineName = medicineName;
    this.dosage = dosage;
    this.time = time;
    this.isTaken = isTaken;
    this.createdAt = createdAt || new Date();
    this.reminderId = reminderId;
    this.frequency = frequency;
    this.notes = notes;
  }

  static fromJSON(json: MedicationRecordJSON): MedicationRecord {
    return new MedicationRecord(
      json.medicineName,
      json.dosage,
      json.time,
      json.isTaken,
      new Date(json.createdAt),
      json.reminderId,
      json.frequency || '每天',
      json.notes || ''
    );
  }

  toJSON(): MedicationRecordJSON {
    return {
      medicineName: this.medicineName,
      dosage: this.dosage,
      time: this.time,
      isTaken: this.isTaken,
      createdAt: this.createdAt.toISOString(),
      reminderId: this.reminderId,
      frequency: this.frequency,
      notes: this.notes
    };
  }
  
  /**
   * 获取格式化的时间显示
   */
  getFormattedTime(): string {
    return this.time;
  }
  
  /**
   * 获取状态文本
   */
  getStatusText(): string {
    return this.isTaken ? '已服用' : '未服用';
  }
  
  /**
   * 获取状态颜色
   */
  getStatusColor(): string {
    return this.isTaken ? '#52c41a' : '#ff4d4f';
  }
}
