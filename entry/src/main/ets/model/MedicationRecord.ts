/**
 * 用药记录JSON接口
 */
export interface MedicationRecordJSON {
  medicineName: string;
  dosage: string;
  time: string;
  isTaken: boolean;
  createdAt: string;
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

  constructor(
    medicineName: string,
    dosage: string,
    time: string,
    isTaken: boolean = false,
    createdAt?: Date
  ) {
    this.medicineName = medicineName;
    this.dosage = dosage;
    this.time = time;
    this.isTaken = isTaken;
    this.createdAt = createdAt || new Date();
  }

  static fromJSON(json: MedicationRecordJSON): MedicationRecord {
    return new MedicationRecord(
      json.medicineName,
      json.dosage,
      json.time,
      json.isTaken,
      new Date(json.createdAt)
    );
  }

  toJSON(): MedicationRecordJSON {
    return {
      medicineName: this.medicineName,
      dosage: this.dosage,
      time: this.time,
      isTaken: this.isTaken,
      createdAt: this.createdAt.toISOString()
    };
  }
}
