import { EmergencyContact, type EmergencyContactJSON } from '../model/EmergencyContact';
import { StorageService } from '../service/StorageService';
import promptAction from '@ohos.promptAction';

@Component
export struct EmergencyPage {
  @State contacts: EmergencyContact[] = [];
  @State name: string = '';
  @State phone: string = '';
  @State relationship: string = '';
  @State isLoading: boolean = true;
  @State showAddForm: boolean = false;
  @State editingIndex: number = -1;
  @State isSOSActive: boolean = false;
  
  private storageService: StorageService = StorageService.getInstance();
  
  aboutToAppear() {
    this.loadContacts();
  }
  
  async loadContacts(): Promise<void> {
    this.isLoading = true;
    try {
      const data = await this.storageService.loadData<EmergencyContactJSON[]>('emergencyContacts');
      this.contacts = data ? data.map(d => EmergencyContact.fromJSON(d)) : [];
    } catch (error) {
      console.error('Failed to load contacts:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async saveContacts(): Promise<void> {
    try {
      await this.storageService.saveData('emergencyContacts', this.contacts.map(c => c.toJSON()));
    } catch (error) {
      console.error('Failed to save contacts:', error);
    }
  }
  
  addContact(): void {
    if (!this.name || !this.phone) {
      promptAction.showToast({ message: '请填写姓名和电话号码' });
      return;
    }
    
    if (this.editingIndex >= 0) {
      // 编辑模式
      this.contacts[this.editingIndex].name = this.name;
      this.contacts[this.editingIndex].phone = this.phone;
      this.contacts[this.editingIndex].relationship = this.relationship;
      this.editingIndex = -1;
      promptAction.showToast({ message: '联系人已更新' });
    } else {
      // 添加模式
      const contact = new EmergencyContact(this.name, this.phone, this.relationship);
      this.contacts.push(contact);
      promptAction.showToast({ message: '联系人已添加' });
    }
    
    this.saveContacts();
    this.resetForm();
  }
  
  editContact(index: number): void {
    this.editingIndex = index;
    this.name = this.contacts[index].name;
    this.phone = this.contacts[index].phone;
    this.relationship = this.contacts[index].relationship;
    this.showAddForm = true;
  }
  
  async deleteContact(index: number): Promise<void> {
    promptAction.showDialog({
      title: '确认删除',
      message: `确定要删除 ${this.contacts[index].name} 吗？`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#ff4d4f' }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        this.contacts.splice(index, 1);
        await this.saveContacts();
        promptAction.showToast({ message: '已删除' });
      }
    });
  }
  
  resetForm(): void {
    this.name = '';
    this.phone = '';
    this.relationship = '';
    this.showAddForm = false;
    this.editingIndex = -1;
  }
  
  /**
   * 拨打电话
   */
  async makeCall(phoneNumber: string): Promise<void> {
    promptAction.showDialog({
      title: '📞 拨打电话',
      message: `请拨打：${phoneNumber}`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '已拨打', color: '#52c41a' }
      ]
    });
  }
  
  /**
   * SOS紧急呼叫
   */
  async triggerSOS(): Promise<void> {
    if (this.contacts.length === 0) {
      promptAction.showToast({ message: '请先添加紧急联系人' });
      return;
    }
    
    this.isSOSActive = true;
    
    promptAction.showDialog({
      title: '🆘 SOS紧急呼叫',
      message: `立即联系 ${this.contacts[0].name}\n电话：${this.contacts[0].phone}`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '立即呼叫', color: '#ff4d4f' }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        await this.makeCall(this.contacts[0].phone);
        promptAction.showToast({ message: 'SOS已触发，请立即拨打紧急联系人电话' });
      }
      this.isSOSActive = false;
    });
  }
  
  /**
   * 快速拨号
   */
  async quickDial(index: number): Promise<void> {
    const contact = this.contacts[index];
    promptAction.showDialog({
      title: `📞 呼叫 ${contact.name}`,
      message: `电话号码：${contact.phone}`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '拨打', color: '#52c41a' }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        await this.makeCall(contact.phone);
      }
    });
  }
  
  /**
   * 发送位置信息提示
   */
  async shareLocation(index: number): Promise<void> {
    const contact = this.contacts[index];
    promptAction.showDialog({
      title: '📍 分享位置',
      message: `将向 ${contact.name} (${contact.phone}) 发送位置信息\n\n请手动发送短信告知您的位置`,
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '知道了', color: '#1890ff' }
      ]
    });
  }
  
  /**
   * 获取关系图标
   */
  getRelationshipIcon(relationship: string): string {
    if (relationship.includes('子女') || relationship.includes('儿子') || relationship.includes('女儿')) {
      return '👨‍👩‍👧‍👦';
    } else if (relationship.includes('配偶') || relationship.includes('妻子') || relationship.includes('丈夫')) {
      return '💑';
    } else if (relationship.includes('医生')) {
      return '👨‍⚕️';
    } else if (relationship.includes('朋友')) {
      return '🤝';
    } else {
      return '👤';
    }
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('🆘 紧急联系')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        Button('+ 添加')
          .fontSize(16)
          .height(40)
          .backgroundColor('#1890ff')
          .onClick(() => this.showAddForm = !this.showAddForm)
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // SOS大按钮
      this.buildSOSButton()
      
      // 添加表单
      if (this.showAddForm) {
        this.buildAddForm()
      }
      
      // 联系人列表
      Scroll() {
        Column() {
          if (this.isLoading) {
            LoadingProgress().width(50).height(50)
          } else if (this.contacts.length === 0) {
            this.buildEmptyState()
          } else {
            ForEach(this.contacts, (contact: EmergencyContact, index: number) => {
              this.buildContactCard(contact, index)
            })
          }
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#f5f5f5')
  }
  
  @Builder
  buildSOSButton() {
    Column() {
      Button() {
        Column() {
          Text('SOS')
            .fontSize(56)
            .fontColor('#ffffff')
            .fontWeight(FontWeight.Bold)
          
          Text('紧急呼叫')
            .fontSize(18)
            .fontColor('#ffffff')
            .margin({ top: 8 })
          
          if (this.contacts.length > 0) {
            Text(`将联系：${this.contacts[0].name}`)
              .fontSize(14)
              .fontColor('#ffffff')
              .opacity(0.8)
              .margin({ top: 4 })
          }
        }
      }
      .width('100%')
      .height(140)
      .backgroundColor(this.isSOSActive ? '#d9363e' : '#f5222d')
      .borderRadius(70)
      .margin({ bottom: 20 })
      .onClick(() => this.triggerSOS())
      .shadow({ radius: 10, color: '#f5222d40', offsetX: 0, offsetY: 5 })
      
      // 快速操作提示
      Row() {
        Text('💡 点击SOS按钮可触发紧急呼叫，系统将提示您拨打联系人电话')
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#fff7e6')
      .borderRadius(8)
      .margin({ bottom: 20 })
    }
  }
  
  @Builder
  buildAddForm() {
    Column() {
      Text(this.editingIndex >= 0 ? '编辑联系人' : '添加紧急联系人')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 15 })
      
      // 姓名
      TextInput({ placeholder: '姓名', text: this.name })
        .width('100%')
        .height(50)
        .fontSize(16)
        .onChange((v) => this.name = v)
        .margin({ bottom: 10 })
      
      // 电话号码
      TextInput({ placeholder: '电话号码', text: this.phone })
        .width('100%')
        .height(50)
        .fontSize(16)
        .type(InputType.PhoneNumber)
        .onChange((v) => this.phone = v)
        .margin({ bottom: 10 })
      
      // 关系选择
      Row() {
        Text('关系：')
          .fontSize(16)
        
        ForEach(['子女', '配偶', '医生', '朋友', '其他'], (rel: string) => {
          Button(rel)
            .fontSize(14)
            .height(36)
            .backgroundColor(this.relationship === rel ? '#1890ff' : '#d9d9d9')
            .fontColor(this.relationship === rel ? '#ffffff' : '#666666')
            .onClick(() => this.relationship = rel)
            .margin({ left: 8 })
        })
      }
      .width('100%')
      .margin({ bottom: 15 })
      
      // 操作按钮
      Row() {
        Button('取消')
          .width('45%')
          .height(50)
          .backgroundColor('#d9d9d9')
          .fontColor('#666666')
          .onClick(() => this.resetForm())
        
        Button(this.editingIndex >= 0 ? '保存' : '添加')
          .width('45%')
          .height(50)
          .backgroundColor('#1890ff')
          .onClick(() => this.addContact())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .margin({ bottom: 20 })
  }
  
  @Builder
  buildEmptyState() {
    Column() {
      Text('📞')
        .fontSize(60)
        .margin({ bottom: 20 })
      
      Text('暂无紧急联系人')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ bottom: 10 })
      
      Text('点击上方"添加"按钮创建联系人')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(40)
  }
  
  @Builder
  buildContactCard(contact: EmergencyContact, index: number) {
    Column() {
      // 联系人信息
      Row() {
        // 头像图标
        Column() {
          Text(this.getRelationshipIcon(contact.relationship))
            .fontSize(40)
        }
        .width(60)
        .height(60)
        .backgroundColor('#f0f0f0')
        .borderRadius(30)
        .justifyContent(FlexAlign.Center)
        
        // 信息
        Column() {
          Row() {
            Text(contact.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            
            if (contact.relationship) {
              Text(contact.relationship)
                .fontSize(12)
                .fontColor('#ffffff')
                .backgroundColor('#1890ff')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ left: 8 })
            }
          }
          .width('100%')
          
          Text(contact.phone)
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 5 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 15 })
        
        // 快速拨号按钮
        Button() {
          Column() {
            Text('📞')
              .fontSize(24)
          }
        }
        .width(60)
        .height(60)
        .backgroundColor('#52c41a')
        .borderRadius(30)
        .onClick(() => this.quickDial(index))
      }
      .width('100%')
      
      // 操作按钮
      Row() {
        Button('发送位置')
          .fontSize(14)
          .height(36)
          .backgroundColor('#1890ff')
          .onClick(() => this.shareLocation(index))
        
        Button('编辑')
          .fontSize(14)
          .height(36)
          .backgroundColor('#fa8c16')
          .margin({ left: 10 })
          .onClick(() => this.editContact(index))
        
        Button('删除')
          .fontSize(14)
          .height(36)
          .backgroundColor('#ff4d4f')
          .margin({ left: 10 })
          .onClick(() => this.deleteContact(index))
      }
      .width('100%')
      .margin({ top: 10 })
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .margin({ bottom: 10 })
    .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 })
  }
}
