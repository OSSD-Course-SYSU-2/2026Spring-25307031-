import { HealthCheckPage } from './HealthCheckPage';
import { MedicationPage } from './MedicationPage';
import { VitalSignPage } from './VitalSignPage';
import { EmergencyPage } from './EmergencyPage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  
  @Builder
  TabBuilder(title: string, icon: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(24)
      
      Text(title)
        .fontSize(12)
        .margin({ top: 4 })
        .fontColor(this.currentIndex === index ? '#1890ff' : '#666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
    })
  }
  
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
        this.TabBuilder('健康打卡', '📋', 0)
        this.TabBuilder('用药提醒', '💊', 1)
        this.TabBuilder('健康指标', '📊', 2)
        this.TabBuilder('紧急联系', '🆘', 3)
      }
      .width('100%')
      .height(70)
      .backgroundColor('#ffffff')
      .justifyContent(FlexAlign.SpaceEvenly)
      .shadow({ radius: 10, color: '#00000010', offsetX: 0, offsetY: -2 })
    }
    .width('100%')
    .height('100%')
  }
}
