import { VitalSignRecord, type VitalSignRecordJSON } from '../model/VitalSignRecord';
import { StorageService } from '../service/StorageService';
import promptAction from '@ohos.promptAction';

@Component
export struct VitalSignPage {
  @State records: VitalSignRecord[] = [];
  @State selectedType: '血压' | '血糖' | '心率' = '血压';
  @State value: string = '';
  @State note: string = '';
  @State isLoading: boolean = true;
  @State showAddForm: boolean = false;
  
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
    if (!this.value) {
      promptAction.showToast({ message: '请输入数值' });
      return;
    }
    
    // 验证数值格式
    if (this.selectedType === '血压') {
      if (!this.value.includes('/')) {
        promptAction.showToast({ message: '血压格式应为：收缩压/舒张压，如：120/80' });
        return;
      }
    }
    
    const record = new VitalSignRecord(this.selectedType, this.value, this.note);
    this.records.unshift(record);
    this.saveRecords();
    
    this.value = '';
    this.note = '';
    this.showAddForm = false;
    
    promptAction.showToast({ message: '记录添加成功！' });
  }
  
  async deleteRecord(index: number): Promise<void> {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除这条记录吗？',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '删除', color: '#ff4d4f' }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        this.records.splice(index, 1);
        await this.saveRecords();
        promptAction.showToast({ message: '已删除' });
      }
    });
  }
  
  getTypeIcon(type: string): string {
    if (type === '血压') return '❤️';
    if (type === '血糖') return '🩸';
    if (type === '心率') return '💓';
    return '📊';
  }
  
  getTypeColor(type: string): string {
    if (type === '血压') return '#ff4d4f';
    if (type === '血糖') return '#fa8c16';
    if (type === '心率') return '#eb2f96';
    return '#1890ff';
  }
  
  getUnit(type: string): string {
    if (type === '血压') return 'mmHg';
    if (type === '血糖') return 'mmol/L';
    if (type === '心率') return '次/分';
    return '';
  }
  
  formatDate(date: Date): string {
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${month}/${day} ${hours}:${minutes}`;
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('📊 健康指标')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        Button('+ 记录')
          .fontSize(16)
          .height(40)
          .backgroundColor('#1890ff')
          .onClick(() => this.showAddForm = !this.showAddForm)
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 类型选择
      Row() {
        Button() {
          Column() {
            Text('❤️').fontSize(20)
            Text('血压').fontSize(14).margin({ top: 4 })
          }
        }
        .width('30%')
        .height(60)
        .backgroundColor(this.selectedType === '血压' ? '#ff4d4f' : '#ffffff')
        .fontColor(this.selectedType === '血压' ? '#ffffff' : '#666666')
        .onClick(() => this.selectedType = '血压')
        
        Button() {
          Column() {
            Text('🩸').fontSize(20)
            Text('血糖').fontSize(14).margin({ top: 4 })
          }
        }
        .width('30%')
        .height(60)
        .backgroundColor(this.selectedType === '血糖' ? '#fa8c16' : '#ffffff')
        .fontColor(this.selectedType === '血糖' ? '#ffffff' : '#666666')
        .onClick(() => this.selectedType = '血糖')
        
        Button() {
          Column() {
            Text('💓').fontSize(20)
            Text('心率').fontSize(14).margin({ top: 4 })
          }
        }
        .width('30%')
        .height(60)
        .backgroundColor(this.selectedType === '心率' ? '#eb2f96' : '#ffffff')
        .fontColor(this.selectedType === '心率' ? '#ffffff' : '#666666')
        .onClick(() => this.selectedType = '心率')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })
      
      // 添加表单
      if (this.showAddForm) {
        Column() {
          Text('添加' + this.selectedType + '记录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })
          
          // 数值输入
          TextInput({ 
            placeholder: this.selectedType === '血压' ? '如：120/80' : '数值',
            text: this.value
          })
            .width('100%')
            .height(50)
            .fontSize(16)
            .onChange((v) => this.value = v)
            .margin({ bottom: 10 })
          
          // 提示信息
          if (this.selectedType === '血压') {
            Text('格式：收缩压/舒张压，如：120/80')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: 10 })
          } else if (this.selectedType === '血糖') {
            Text('单位：mmol/L，正常范围：3.9-6.1')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: 10 })
          } else {
            Text('单位：次/分，正常范围：60-100')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: 10 })
          }
          
          // 备注
          TextInput({ placeholder: '备注（可选）', text: this.note })
            .width('100%')
            .height(50)
            .fontSize(16)
            .onChange((v) => this.note = v)
            .margin({ bottom: 15 })
          
          // 操作按钮
          Row() {
            Button('取消')
              .width('45%')
              .height(50)
              .backgroundColor('#d9d9d9')
              .fontColor('#666666')
              .onClick(() => this.showAddForm = false)
            
            Button('保存')
              .width('45%')
              .height(50)
              .backgroundColor('#1890ff')
              .onClick(() => this.addRecord())
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
      
      // 记录列表
      Scroll() {
        Column() {
          if (this.isLoading) {
            LoadingProgress().width(50).height(50)
          } else if (this.records.filter(r => r.type === this.selectedType).length === 0) {
            Column() {
              Text('📝').fontSize(60).margin({ bottom: 20 })
              Text('暂无记录').fontSize(18).fontColor('#666666').margin({ bottom: 10 })
              Text('点击上方"记录"按钮添加数据').fontSize(14).fontColor('#999999')
            }
            .width('100%')
            .padding(40)
          } else {
            ForEach(this.records.filter(r => r.type === this.selectedType), (record: VitalSignRecord, index: number) => {
              Row() {
                // 左侧图标和时间
                Column() {
                  Text(this.getTypeIcon(record.type)).fontSize(32)
                  Text(this.formatDate(record.createdAt)).fontSize(12).fontColor('#999999').margin({ top: 5 })
                }
                .width(60)
                
                // 中间数值和备注
                Column() {
                  Row() {
                    Text(record.value).fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.getTypeColor(record.type))
                    Text(this.getUnit(record.type)).fontSize(14).fontColor('#666666').margin({ left: 4 })
                  }
                  
                  if (record.note) {
                    Text(record.note).fontSize(14).fontColor('#666666').margin({ top: 5 })
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 15 })
                
                // 右侧删除按钮
                Button('删除')
                  .fontSize(14)
                  .height(36)
                  .backgroundColor('#ff4d4f')
                  .onClick(() => this.deleteRecord(index))
              }
              .width('100%')
              .padding(15)
              .backgroundColor('#ffffff')
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
