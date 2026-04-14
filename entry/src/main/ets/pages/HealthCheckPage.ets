import { HealthCheckRecord, type HealthCheckRecordJSON } from '../model/HealthCheckRecord';
import { StorageService } from '../service/StorageService';

@Component
export struct HealthCheckPage {
  // 当前选择的健康状态
  @State currentStatus: '良好' | '一般' | '不适' = '良好';
  
  // 历史记录列表
  @State healthRecords: HealthCheckRecord[] = [];
  
  // 备注信息
  @State note: string = '';
  
  // 加载状态
  @State isLoading: boolean = true;
  
  // 存储服务实例
  private storageService: StorageService = StorageService.getInstance();
  
  // 统计计数
  @State goodCount: number = 0;
  @State normalCount: number = 0;
  @State badCount: number = 0;
  
  /**
   * 页面即将显示时调用
   */
  aboutToAppear() {
    this.loadHealthRecords();
  }
  
  /**
   * 页面即将消失时调用
   */
  aboutToDisappear() {
    this.saveHealthRecords();
  }
  
  /**
   * 加载健康记录
   */
  async loadHealthRecords(): Promise<void> {
    console.log('loadHealthRecords called');
    this.isLoading = true;
    try {
      console.log('Loading health records from storage...');
      const recordsData: HealthCheckRecordJSON[] = await this.storageService.loadHealthRecords();
      console.log('Raw records data loaded:', recordsData);
      
      this.healthRecords = recordsData.map(recordData => 
        HealthCheckRecord.fromJSON(recordData)
      );
      
      console.log('Parsed health records:', this.healthRecords);
      
      // 更新统计计数
      this.goodCount = this.healthRecords.filter(r => r.healthStatus === '良好').length;
      this.normalCount = this.healthRecords.filter(r => r.healthStatus === '一般').length;
      this.badCount = this.healthRecords.filter(r => r.healthStatus === '不适').length;
      
      console.log(`Loaded ${this.healthRecords.length} health records`);
      console.log('Counts - good:', this.goodCount, 'normal:', this.normalCount, 'bad:', this.badCount);
    } catch (error) {
      console.error('Failed to load health records:', error);
    } finally {
      this.isLoading = false;
      console.log('loadHealthRecords completed');
    }
  }
  
  /**
   * 保存健康记录
   */
  async saveHealthRecords(): Promise<void> {
    try {
      const recordsData: HealthCheckRecordJSON[] = this.healthRecords.map(record => record.toJSON());
      await this.storageService.saveHealthRecords(recordsData);
      console.log(`Saved ${this.healthRecords.length} health records`);
    } catch (error) {
      console.error('Failed to save health records:', error);
    }
  }
  
  /**
   * 构建页面
   */
  build() {
    Column() {
      // 应用标题
      this.buildHeader()
      
      // 滚动区域
      Scroll() {
        Column() {
          // 加载状态显示
          if (this.isLoading) {
            this.buildLoadingIndicator()
          } else {
            // 状态选择区域
            this.buildStatusSelector()
            
            // 备注输入区域
            this.buildNoteInput()
            
            // 提交按钮
            this.buildSubmitButton()
            
            // 历史记录列表
            this.buildHistoryList()
          }
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  /**
   * 构建加载指示器
   */
  @Builder
  buildLoadingIndicator() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#1890ff')
      
      Text('加载中...')
        .fontSize(18)
        .fontColor('#666')
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  
  /**
   * 构建应用标题
   */
  @Builder
  buildHeader() {
    Column() {
      Text('健康打卡')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ bottom: 10 })
      
      Text('关爱老人健康，每日打卡')
        .fontSize(18)
        .fontColor('#666')
    }
    .width('100%')
    .padding({ top: 30, bottom: 30 })
    .alignItems(HorizontalAlign.Center)
  }
  
  /**
   * 构建状态选择器
   */
  @Builder
  buildStatusSelector() {
    Column() {
      Text('选择健康状态')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .margin({ bottom: 20 })
        .width('100%')
        .textAlign(TextAlign.Start)
      
      Row({ space: 20 }) {
        // 良好状态
        this.buildStatusButton('良好', '😊', '#52c41a')
        
        // 一般状态
        this.buildStatusButton('一般', '😐', '#faad14')
        
        // 不适状态
        this.buildStatusButton('不适', '😷', '#f5222d')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(25)
    .backgroundColor('#ffffff')
    .borderRadius(16)
    .margin({ bottom: 20 })
    .shadow({ radius: 3, color: '#00000008', offsetX: 0, offsetY: 1 })
  }
  
  /**
   * 构建状态按钮
   */
  @Builder
  buildStatusButton(status: '良好' | '一般' | '不适', emoji: string, color: string) {
    Button() {
      Column({ space: 8 }) {
        Text(emoji)
          .fontSize(32)
        
        Text(status)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
      }
    }
    .width(80)
    .height(80)
    .backgroundColor(this.currentStatus === status ? color : '#f5f5f5')
    .borderRadius(12)
    .border({ width: this.currentStatus === status ? 2 : 0, color })
    .onClick(() => {
      this.currentStatus = status;
    })
  }
  
  /**
   * 构建备注输入
   */
  @Builder
  buildNoteInput() {
    Column() {
      Text('备注（可选）')
        .fontSize(18)
        .fontColor('#333')
        .margin({ bottom: 10 })
        .width('100%')
        .textAlign(TextAlign.Start)
      
      TextInput({ placeholder: '输入备注信息...', text: this.note })
        .width('100%')
        .height(100)
        .padding(15)
        .backgroundColor('#ffffff')
        .borderRadius(12)
        .border({ width: 1, color: '#e8e8e8' })
        .onChange((value: string) => {
          this.note = value;
        })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }
  
  /**
   * 构建提交按钮
   */
  @Builder
  buildSubmitButton() {
    Button('提交打卡')
      .fontSize(20)
      .fontColor('#ffffff')
      .backgroundColor('#1890ff')
      .width('100%')
      .height(55)
      .margin({ bottom: 30 })
      .borderRadius(12)
      .onClick(() => {
        this.submitHealthCheck();
      })
  }
  
  /**
   * 构建历史记录列表
   */
  @Builder
  buildHistoryList() {
    Column() {
      // 统计信息和操作按钮行
      Row() {
        Column() {
          Text('今日记录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          
          Text(`共 ${this.healthRecords.length} 条记录`)
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        
        // 清除按钮
        if (this.healthRecords.length > 0) {
          Button('清除记录')
            .fontSize(14)
            .fontColor('#f5222d')
            .backgroundColor('#fff1f0')
            .border({ width: 1, color: '#ffa39e' })
            .borderRadius(8)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              this.clearAllRecords();
            })
        }
      }
      .width('100%')
      .margin({ bottom: 15 })
      
      // 统计卡片
      if (this.healthRecords.length > 0) {
        Column() {
          this.buildStatsCard()
        }
        .margin({ bottom: 20 })
      }
      
      if (this.healthRecords.length === 0) {
        // 无记录时的提示
        Column() {
          Text('📊')
            .fontSize(60)
            .margin({ bottom: 15 })
          
          Text('暂无打卡记录')
            .fontSize(20)
            .fontColor('#999')
          
          Text('点击上方按钮提交今日健康状态')
            .fontSize(16)
            .fontColor('#ccc')
            .margin({ top: 5 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#ffffff')
        .borderRadius(16)
      } else {
        // 显示记录列表
        Scroll() {
          Column() {
            ForEach(this.healthRecords, (record: HealthCheckRecord) => {
              this.buildRecordItem(record)
            })
          }
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .height(300)
        .backgroundColor('#ffffff')
        .borderRadius(16)
        .padding(15)
      }
    }
    .width('100%')
  }
  
  /**
   * 构建统计卡片
   */
  @Builder
  buildStatsCard() {
    Row({ space: 15 }) {
      // 良好状态统计
      Column() {
        Text('😊')
          .fontSize(24)
        Text(this.goodCount.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#52c41a')
          .margin({ top: 5 })
        Text('良好')
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .padding(15)
      .backgroundColor('#f6ffed')
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)
      
      // 一般状态统计
      Column() {
        Text('😐')
          .fontSize(24)
        Text(this.normalCount.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#faad14')
          .margin({ top: 5 })
        Text('一般')
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .padding(15)
      .backgroundColor('#fffbe6')
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)
      
      // 不适状态统计
      Column() {
        Text('😷')
          .fontSize(24)
        Text(this.badCount.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#f5222d')
          .margin({ top: 5 })
        Text('不适')
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .padding(15)
      .backgroundColor('#fff1f0')
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#ffffff')
    .borderRadius(16)
    .shadow({ radius: 3, color: '#00000008', offsetX: 0, offsetY: 1 })
  }
  
  /**
   * 构建单个记录项
   */
  @Builder
  buildRecordItem(record: HealthCheckRecord) {
    Row() {
      // 状态图标和文字
      Column({ space: 5 }) {
        Text(record.getStatusIcon())
          .fontSize(28)
          .fontColor(record.getStatusColor())
        
        Text(record.healthStatus)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(record.getStatusColor())
      }
      .width(80)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      
      // 日期和时间
      Column({ space: 5 }) {
        Text(record.getFormattedDate().split(' ')[0])
          .fontSize(20)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
        
        Text(record.getFormattedDate().split(' ')[1])
          .fontSize(16)
          .fontColor('#666')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      
      // 备注信息（如果有）
      if (record.note) {
        Text(record.note)
          .fontSize(16)
          .fontColor('#999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(100)
      }
    }
    .width('100%')
    .height(70)
    .padding({ left: 15, right: 15 })
    .backgroundColor('#fafafa')
    .borderRadius(12)
    .margin({ bottom: 10 })
  }
  
  /**
   * 提交健康打卡
   */
  async submitHealthCheck() {
    console.log('submitHealthCheck called, currentStatus:', this.currentStatus, 'note:', this.note);
    
    // 创建新的健康记录
    const newRecord = new HealthCheckRecord(
      this.currentStatus,
      this.note
    );
    
    console.log('New record created:', newRecord);
    
    // 添加到记录列表
    this.healthRecords = [newRecord, ...this.healthRecords];
    
    // 更新统计计数
    this.goodCount = this.healthRecords.filter(r => r.healthStatus === '良好').length;
    this.normalCount = this.healthRecords.filter(r => r.healthStatus === '一般').length;
    this.badCount = this.healthRecords.filter(r => r.healthStatus === '不适').length;
    
    console.log('Updated counts - good:', this.goodCount, 'normal:', this.normalCount, 'bad:', this.badCount);
    
    // 清空备注
    this.note = '';
    
    try {
      // 保存到持久化存储
      await this.saveHealthRecords();
      
      console.log('Health records saved successfully');
      
      // 显示成功提示
      AlertDialog.show({
        title: '打卡成功',
        message: `已记录今日健康状态：${this.currentStatus}`,
        confirm: {
          value: '确定',
          action: () => {
            console.log('打卡成功提示已关闭');
          }
        }
      });
    } catch (error) {
      console.error('Failed to save health record:', error);
      AlertDialog.show({
        title: '保存失败',
        message: '无法保存打卡记录，请重试',
        confirm: {
          value: '确定',
          action: () => {
            console.log('错误提示已关闭');
          }
        }
      });
    }
  }
  
  /**
   * 清除所有历史记录
   */
  async clearAllRecords() {
    AlertDialog.show({
      title: '确认清除',
      message: '确定要清除所有历史记录吗？此操作不可恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
          console.log('取消清除操作');
        }
      },
      secondaryButton: {
        value: '清除',
        action: async () => {
          try {
            this.healthRecords = [];
            
            // 更新统计计数
            this.goodCount = 0;
            this.normalCount = 0;
            this.badCount = 0;
            
            await this.storageService.clearAllData();
            console.log('All health records cleared');
            
            // 显示清除成功提示
            AlertDialog.show({
              title: '清除成功',
              message: '所有历史记录已清除',
              confirm: {
                value: '确定',
                action: () => {
                  console.log('清除成功提示已关闭');
                }
              }
            });
          } catch (error) {
            console.error('Failed to clear health records:', error);
            AlertDialog.show({
              title: '清除失败',
              message: '无法清除历史记录，请重试',
              confirm: {
                value: '确定',
                action: () => {
                  console.log('错误提示已关闭');
                }
              }
            });
          }
        }
      }
    });
  }
}