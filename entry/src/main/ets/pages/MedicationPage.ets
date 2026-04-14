import { MedicationRecord, type MedicationRecordJSON } from '../model/MedicationRecord';
import { StorageService } from '../service/StorageService';

@Component
export struct MedicationPage {
  @State medications: MedicationRecord[] = [];
  @State medicineName: string = '';
  @State dosage: string = '';
  @State selectedTime: string = '08:00';
  @State isLoading: boolean = true;
  
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
    if (!this.medicineName || !this.dosage) return;
    
    const medication = new MedicationRecord(this.medicineName, this.dosage, this.selectedTime);
    this.medications.push(medication);
    this.saveMedications();
    
    this.medicineName = '';
    this.dosage = '';
  }
  
  toggleTaken(index: number): void {
    this.medications[index].isTaken = !this.medications[index].isTaken;
    this.saveMedications();
  }
  
  deleteMedication(index: number): void {
    this.medications.splice(index, 1);
    this.saveMedications();
  }
  
  build() {
    Column() {
      // 标题
      Text('💊 用药提醒')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      // 滚动区域
      Scroll() {
        Column() {
          // 添加用药表单
          Column() {
            TextInput({ placeholder: '药品名称' })
              .width('100%')
              .height(50)
              .onChange((value) => this.medicineName = value)
              .margin({ bottom: 10 })
            
            TextInput({ placeholder: '剂量（如：1片）' })
              .width('100%')
              .height(50)
              .onChange((value) => this.dosage = value)
              .margin({ bottom: 10 })
            
            Row() {
              Text('服药时间：')
              Text(this.selectedTime)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .margin({ bottom: 10 })
            
            Button('添加提醒')
              .width('100%')
              .height(50)
              .backgroundColor('#1890ff')
              .onClick(() => this.addMedication())
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .margin({ bottom: 20 })
          
          // 用药列表
          if (this.isLoading) {
            LoadingProgress().width(50).height(50)
          } else {
            ForEach(this.medications, (med: MedicationRecord, index: number) => {
              Row() {
                Column() {
                  Text(`${med.medicineName} ${med.dosage}`)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                  
                  Text(`服药时间：${med.time}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ top: 5 })
                }
                .layoutWeight(1)
                
                Toggle({ type: ToggleType.Checkbox, isOn: med.isTaken })
                  .onChange((isOn) => this.toggleTaken(index))
                
                Button('删除')
                  .fontSize(14)
                  .height(40)
                  .backgroundColor('#ff4d4f')
                  .onClick(() => this.deleteMedication(index))
              }
              .width('100%')
              .padding(15)
              .backgroundColor(med.isTaken ? '#f6ffed' : '#ffffff')
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
