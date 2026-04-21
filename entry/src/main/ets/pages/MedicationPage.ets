import { MedicationRecord, type MedicationRecordJSON } from '../model/MedicationRecord';
import { StorageService } from '../service/StorageService';
import promptAction from '@ohos.promptAction';

@Component
export struct MedicationPage {
  @State medications: MedicationRecord[] = [];
  @State medicineName: string = '';
  @State dosage: string = '';
  @State selectedTime: string = '08:00';
  @State frequency: string = '每天';
  @State notes: string = '';
  @State isLoading: boolean = true;
  @State showAddForm: boolean = false;
  @State selectedHour: number = 8;
  @State selectedMinute: number = 0;
  
  private storageService: StorageService = StorageService.getInstance();
  
  aboutToAppear() {
    this.loadMedications();
  }
  
  async loadMedications(): Promise<void> {
    this.isLoading = true;
    try {
      const data = await this.storageService.loadData<MedicationRecordJSON[]>('medications');
      this.medications = data ? data.map(d => MedicationRecord.fromJSON(d)) : [];
    } catch (error) {
      console.error('Failed to load medications:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async saveMedications(): Promise<void> {
    try {
      await this.storageService.saveData('medications', this.medications.map(m => m.toJSON()));
    } catch (error) {
      console.error('Failed to save medications:', error);
    }
  }
  
  addMedication(): void {
    if (!this.medicineName || !this.dosage) {
      promptAction.showToast({ message: '请填写药品名称和剂量' });
      return;
    }
    
    const medication = new MedicationRecord(
      this.medicineName,
      this.dosage,
      this.selectedTime,
      false,
      new Date(),
      Date.now(),
      this.frequency,
      this.notes
    );
    
    this.medications.push(medication);
    this.saveMedications();
    
    // 清空表单
    this.medicineName = '';
    this.dosage = '';
    this.notes = '';
    this.showAddForm = false;
    
    promptAction.showToast({ message: '用药提醒添加成功！' });
  }
  
  toggleTaken(index: number): void {
    this.medications[index].isTaken = !this.medications[index].isTaken;
    this.saveMedications();
    
    const status = this.medications[index].isTaken ? '已服用' : '未服用';
    promptAction.showToast({ message: '状态已更新：' + status });
  }
  
  async deleteMedication(index: number): Promise<void> {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除 ' + this.medications[index].medicineName + ' 的用药提醒吗？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#ff4d4f' }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        this.medications.splice(index, 1);
        await this.saveMedications();
        promptAction.showToast({ message: '已删除' });
      }
    });
  }
  
  updateTime(): void {
    this.selectedTime = this.selectedHour.toString().padStart(2, '0') + ':' + this.selectedMinute.toString().padStart(2, '0');
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('💊 用药提醒')
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
      
      // 添加表单
      if (this.showAddForm) {
        Column() {
          Text('添加用药提醒')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })
          
          // 药品名称
          TextInput({ placeholder: '药品名称', text: this.medicineName })
            .width('100%')
            .height(50)
            .fontSize(16)
            .onChange((value) => this.medicineName = value)
            .margin({ bottom: 10 })
          
          // 剂量
          TextInput({ placeholder: '剂量（如：1片、5ml）', text: this.dosage })
            .width('100%')
            .height(50)
            .fontSize(16)
            .onChange((value) => this.dosage = value)
            .margin({ bottom: 10 })
          
          // 服药时间
          Row() {
            Text('服药时间：')
              .fontSize(16)
            
            // 小时选择
            Row() {
              Text(this.selectedHour.toString().padStart(2, '0'))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
              
              Column() {
                Text('▲')
                  .fontSize(16)
                  .onClick(() => {
                    this.selectedHour = (this.selectedHour + 1) % 24;
                    this.updateTime();
                  })
                Text('▼')
                  .fontSize(16)
                  .margin({ top: 5 })
                  .onClick(() => {
                    this.selectedHour = (this.selectedHour - 1 + 24) % 24;
                    this.updateTime();
                  })
              }
              .margin({ left: 8 })
            }
            .padding(10)
            .backgroundColor('#f0f0f0')
            .borderRadius(8)
            
            Text(':')
              .fontSize(24)
              .margin({ left: 8, right: 8 })
            
            // 分钟选择
            Row() {
              Text(this.selectedMinute.toString().padStart(2, '0'))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
              
              Column() {
                Text('▲')
                  .fontSize(16)
                  .onClick(() => {
                    this.selectedMinute = (this.selectedMinute + 5) % 60;
                    this.updateTime();
                  })
                Text('▼')
                  .fontSize(16)
                  .margin({ top: 5 })
                  .onClick(() => {
                    this.selectedMinute = (this.selectedMinute - 5 + 60) % 60;
                    this.updateTime();
                  })
              }
              .margin({ left: 8 })
            }
            .padding(10)
            .backgroundColor('#f0f0f0')
            .borderRadius(8)
          }
          .width('100%')
          .margin({ bottom: 10 })
          
          // 服药频率
          Row() {
            Text('服药频率：')
              .fontSize(16)
            
            Button('每天')
              .fontSize(14)
              .height(36)
              .backgroundColor(this.frequency === '每天' ? '#1890ff' : '#d9d9d9')
              .fontColor(this.frequency === '每天' ? '#ffffff' : '#666666')
              .onClick(() => this.frequency = '每天')
              .margin({ left: 8 })
            
            Button('隔天')
              .fontSize(14)
              .height(36)
              .backgroundColor(this.frequency === '隔天' ? '#1890ff' : '#d9d9d9')
              .fontColor(this.frequency === '隔天' ? '#ffffff' : '#666666')
              .onClick(() => this.frequency = '隔天')
              .margin({ left: 8 })
            
            Button('每周')
              .fontSize(14)
              .height(36)
              .backgroundColor(this.frequency === '每周' ? '#1890ff' : '#d9d9d9')
              .fontColor(this.frequency === '每周' ? '#ffffff' : '#666666')
              .onClick(() => this.frequency = '每周')
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ bottom: 10 })
          
          // 备注
          TextInput({ placeholder: '备注（可选）', text: this.notes })
            .width('100%')
            .height(50)
            .fontSize(16)
            .onChange((value) => this.notes = value)
            .margin({ bottom: 15 })
          
          // 操作按钮
          Row() {
            Button('取消')
              .width('45%')
              .height(50)
              .backgroundColor('#d9d9d9')
              .fontColor('#666666')
              .onClick(() => this.showAddForm = false)
            
            Button('添加提醒')
              .width('45%')
              .height(50)
              .backgroundColor('#1890ff')
              .onClick(() => this.addMedication())
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
      
      // 统计信息
      Row() {
        Column() {
          Text(this.medications.length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890ff')
          Text('总提醒')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        
        Column() {
          Text(this.medications.filter(m => !m.isTaken).length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ff4d4f')
          Text('待服用')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        
        Column() {
          Text(this.medications.filter(m => m.isTaken).length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#52c41a')
          Text('已服用')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .margin({ bottom: 20 })
      
      // 用药列表
      Scroll() {
        Column() {
          if (this.isLoading) {
            LoadingProgress().width(50).height(50)
          } else if (this.medications.length === 0) {
            Column() {
              Text('📝').fontSize(60).margin({ bottom: 20 })
              Text('暂无用药提醒').fontSize(18).fontColor('#666666').margin({ bottom: 10 })
              Text('点击上方"添加"按钮创建提醒').fontSize(14).fontColor('#999999')
            }
            .width('100%')
            .padding(40)
          } else {
            ForEach(this.medications, (med: MedicationRecord, index: number) => {
              Column() {
                Row() {
                  // 左侧信息
                  Column() {
                    Row() {
                      Text(med.medicineName).fontSize(18).fontWeight(FontWeight.Bold)
                      Text(med.dosage).fontSize(16).fontColor('#666666').margin({ left: 8 })
                    }
                    .width('100%')
                    
                    Row() {
                      Text('🕐 ' + med.time).fontSize(14).fontColor('#666666')
                      Text('| ' + med.frequency).fontSize(14).fontColor('#666666').margin({ left: 8 })
                    }
                    .width('100%')
                    .margin({ top: 5 })
                    
                    if (med.notes) {
                      Text('备注：' + med.notes).fontSize(12).fontColor('#999999').margin({ top: 5 })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  
                  // 右侧操作
                  Column() {
                    Toggle({ type: ToggleType.Checkbox, isOn: med.isTaken })
                      .onChange(() => this.toggleTaken(index))
                    
                    Text(med.isTaken ? '已服用' : '未服用')
                      .fontSize(12)
                      .fontColor(med.isTaken ? '#52c41a' : '#ff4d4f')
                      .margin({ top: 5 })
                  }
                  .width(60)
                }
                .width('100%')
                
                // 删除按钮
                Row() {
                  Button('删除')
                    .fontSize(14)
                    .height(36)
                    .backgroundColor('#ff4d4f')
                    .onClick(() => this.deleteMedication(index))
                }
                .width('100%')
                .margin({ top: 10 })
                .justifyContent(FlexAlign.End)
              }
              .width('100%')
              .padding(15)
              .backgroundColor(med.isTaken ? '#f6ffed' : '#ffffff')
              .borderRadius(12)
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
