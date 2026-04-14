import { VitalSignRecord, type VitalSignRecordJSON } from '../model/VitalSignRecord';
import { StorageService } from '../service/StorageService';

@Component
export struct VitalSignPage {
  @State records: VitalSignRecord[] = [];
  @State selectedType: '血压' | '血糖' | '心率' = '血压';
  @State value: string = '';
  @State note: string = '';
  @State isLoading: boolean = true;
  
  private storageService: StorageService = StorageService.getInstance();
  
  aboutToAppear() {
    this.loadRecords();
  }
  
  async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const data = await this.storageService.loadData<VitalSignRecordJSON[]>('vitalSigns');
      this.records = data ? data.map(d => VitalSignRecord.fromJSON(d)) : [];
    } catch (error) {
      console.error('Failed to load vital signs:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async saveRecords(): Promise<void> {
    try {
      await this.storageService.saveData('vitalSigns', this.records.map(r => r.toJSON()));
    } catch (error) {
      console.error('Failed to save vital signs:', error);
    }
  }
  
  addRecord(): void {
    if (!this.value) return;
    
    const record = new VitalSignRecord(this.selectedType, this.value, this.note);
    this.records.unshift(record);
    this.saveRecords();
    
    this.value = '';
    this.note = '';
  }
  
  deleteRecord(index: number): void {
    this.records.splice(index, 1);
    this.saveRecords();
  }
  
  getTypeIcon(type: string): string {
    switch (type) {
      case '血压': return '❤️';
      case '血糖': return '🩸';
      case '心率': return '💓';
      default: return '📊';
    }
  }
  
  build() {
    Column() {
      // 标题
      Text('📊 健康指标')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      // 滚动区域
      Scroll() {
        Column() {
          // 添加记录表单
          Column() {
            Row() {
              ForEach(['血压', '血糖', '心率'], (type: string) => {
                Button(type)
                  .width('30%')
                  .height(40)
                  .backgroundColor(this.selectedType === type ? '#1890ff' : '#d9d9d9')
                  .onClick(() => this.selectedType = type as '血压' | '血糖' | '心率')
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 15 })
            
            TextInput({ placeholder: this.selectedType === '血压' ? '如：120/80' : '数值' })
              .width('100%')
              .height(50)
              .onChange((v) => this.value = v)
              .margin({ bottom: 10 })
            
            TextInput({ placeholder: '备注（可选）' })
              .width('100%')
              .height(50)
              .onChange((v) => this.note = v)
              .margin({ bottom: 10 })
            
            Button('记录')
              .width('100%')
              .height(50)
              .backgroundColor('#52c41a')
              .onClick(() => this.addRecord())
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .margin({ bottom: 20 })
          
          // 记录列表
          if (this.isLoading) {
            LoadingProgress().width(50).height(50)
          } else {
            ForEach(this.records, (record: VitalSignRecord, index: number) => {
              Row() {
                Text(this.getTypeIcon(record.type))
                  .fontSize(24)
                  .margin({ right: 10 })
                
                Column() {
                  Text(`${record.type}: ${record.value}`)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                  
                  if (record.note) {
                    Text(record.note)
                      .fontSize(14)
                      .fontColor('#666')
                      .margin({ top: 5 })
                  }
                  
                  Text(new Date(record.createdAt).toLocaleString())
                    .fontSize(12)
                    .fontColor('#999')
                    .margin({ top: 5 })
                }
                .layoutWeight(1)
                
                Button('删除')
                  .fontSize(14)
                  .height(40)
                  .backgroundColor('#ff4d4f')
                  .onClick(() => this.deleteRecord(index))
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
