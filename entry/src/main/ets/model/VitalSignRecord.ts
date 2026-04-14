/**
 * 生命体征记录JSON接口
 */
export interface VitalSignRecordJSON {
  type: '血压' | '血糖' | '心率';
  value: string;
  note: string;
  createdAt: string;
}

/**
 * 生命体征记录模型
 */
export class VitalSignRecord {
  type: '血压' | '血糖' | '心率';
  value: string;
  note: string;
  createdAt: Date;

  constructor(
    type: '血压' | '血糖' | '心率',
    value: string,
    note: string = '',
    createdAt?: Date
  ) {
    this.type = type;
    this.value = value;
    this.note = note;
    this.createdAt = createdAt || new Date();
  }

  static fromJSON(json: VitalSignRecordJSON): VitalSignRecord {
    return new VitalSignRecord(
      json.type,
      json.value,
      json.note || '',
      new Date(json.createdAt)
    );
  }

  toJSON(): VitalSignRecordJSON {
    return {
      type: this.type,
      value: this.value,
      note: this.note,
      createdAt: this.createdAt.toISOString()
    };
  }
}
