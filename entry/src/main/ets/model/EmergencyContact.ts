/**
 * 紧急联系人JSON接口
 */
export interface EmergencyContactJSON {
  name: string;
  phone: string;
  relationship: string;
}

/**
 * 紧急联系人模型
 */
export class EmergencyContact {
  name: string;
  phone: string;
  relationship: string;

  constructor(name: string, phone: string, relationship: string) {
    this.name = name;
    this.phone = phone;
    this.relationship = relationship;
  }

  static fromJSON(json: EmergencyContactJSON): EmergencyContact {
    return new EmergencyContact(json.name, json.phone, json.relationship);
  }

  toJSON(): EmergencyContactJSON {
    return {
      name: this.name,
      phone: this.phone,
      relationship: this.relationship
    };
  }
}
