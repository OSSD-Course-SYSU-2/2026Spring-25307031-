import { HealthCheckPage } from './HealthCheckPage';
import { MedicationPage } from './MedicationPage';
import { VitalSignPage } from './VitalSignPage';
import { EmergencyPage } from './EmergencyPage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  
  build() {
    Column() {
      // 内容区域
      Stack() {
        if (this.currentIndex === 0) {
          HealthCheckPage()
        } else if (this.currentIndex === 1) {
          MedicationPage()
        } else if (this.currentIndex === 2) {
          VitalSignPage()
        } else if (this.currentIndex === 3) {
          EmergencyPage()
        }
      }
      .width('100%')
      .layoutWeight(1)
      
      // 底部导航栏
      Row() {
        // 健康打卡
        Column() {
          Text('📋')
            .fontSize(24)
          Text('健康打卡')
            .fontSize(12)
            .margin({ top: 4 })
            .fontColor(this.currentIndex === 0 ? '#1890ff' : '#666666')
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 0;
        })
        
        // 用药提醒
        Column() {
          Text('💊')
            .fontSize(24)
          Text('用药提醒')
            .fontSize(12)
            .margin({ top: 4 })
            .fontColor(this.currentIndex === 1 ? '#1890ff' : '#666666')
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 1;
        })
        
        // 健康指标
        Column() {
          Text('📊')
            .fontSize(24)
          Text('健康指标')
            .fontSize(12)
            .margin({ top: 4 })
            .fontColor(this.currentIndex === 2 ? '#1890ff' : '#666666')
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 2;
        })
        
        // 紧急联系
        Column() {
          Text('🆘')
            .fontSize(24)
          Text('紧急联系')
            .fontSize(12)
            .margin({ top: 4 })
            .fontColor(this.currentIndex === 3 ? '#1890ff' : '#666666')
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentIndex = 3;
        })
      }
      .width('100%')
      .height(70)
      .backgroundColor('#ffffff')
      .shadow({ radius: 10, color: '#00000015', offsetX: 0, offsetY: -2 })
    }
    .width('100%')
    .height('100%')
  }
}
