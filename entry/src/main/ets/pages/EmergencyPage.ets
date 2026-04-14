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
    if (!this.name || !this.phone) return;
    
    const contact = new EmergencyContact(this.name, this.phone, this.relationship);
    this.contacts.push(contact);
    this.saveContacts();
    
    this.name = '';
    this.phone = '';
    this.relationship = '';
  }
  
  deleteContact(index: number): void {
    this.contacts.splice(index, 1);
    this.saveContacts();
  }
  
  makeCall(phoneNumber: string): void {
    // 提示用户拨打电话
    promptAction.showToast({
      message: `请拨打：${phoneNumber}`,
      duration: 3000
    });
  }
  
  build() {
    Column() {
      // 标题
      Text('🆘 紧急联系')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      // 滚动区域
      Scroll() {
        Column() {
          // SOS 大按钮
          Button() {
            Column() {
              Text('SOS')
                .fontSize(48)
                .fontColor('#ffffff')
                .fontWeight(FontWeight.Bold)
              
              Text('紧急呼叫')
                .fontSize(16)
                .fontColor('#ffffff')
            }
          }
          .width('100%')
          .height(120)
          .backgroundColor('#f5222d')
          .borderRadius(60)
          .margin({ bottom: 20 })
          .onClick(() => {
            if (this.contacts.length > 0) {
              this.makeCall(this.contacts[0].phone);
            }
          })
          
          // 添加联系人表单
          Column() {
            TextInput({ placeholder: '姓名' })
              .width('100%')
              .height(50)
              .onChange((v) => this.name = v)
              .margin({ bottom: 10 })
            
            TextInput({ placeholder: '电话号码' })
              .width('100%')
              .height(50)
              .type(InputType.PhoneNumber)
              .onChange((v) => this.phone = v)
              .margin({ bottom: 10 })
            
            TextInput({ placeholder: '关系（如：子女、配偶）' })
              .width('100%')
              .height(50)
              .onChange((v) => this.relationship = v)
              .margin({ bottom: 10 })
            
            Button('添加联系人')
              .width('100%')
              .height(50)
              .backgroundColor('#1890ff')
              .onClick(() => this.addContact())
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .margin({ bottom: 20 })
          
          // 联系人列表
          if (this.isLoading) {
            LoadingProgress().width(50).height(50)
          } else {
            ForEach(this.contacts, (contact: EmergencyContact, index: number) => {
              Row() {
                Column() {
                  Text(contact.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                  
                  if (contact.relationship) {
                    Text(contact.relationship)
                      .fontSize(14)
                      .fontColor('#666')
                      .margin({ top: 5 })
                  }
                  
                  Text(contact.phone)
                    .fontSize(14)
                    .fontColor('#1890ff')
                    .margin({ top: 5 })
                }
                .layoutWeight(1)
                
                Button('呼叫')
                  .fontSize(14)
                  .height(40)
                  .backgroundColor('#52c41a')
                  .onClick(() => this.makeCall(contact.phone))
                
                Button('删除')
                  .fontSize(14)
                  .height(40)
                  .backgroundColor('#ff4d4f')
                  .margin({ left: 10 })
                  .onClick(() => this.deleteContact(index))
              }
              .width('100%')
              .padding(15)
              .backgroundColor('#ffffff')
              .borderRadius(8)
              .margin({ bottom: 10 })
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
}
