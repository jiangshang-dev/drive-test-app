import { createSSRApp } from 'vue'
import pinia from './stores'

import share from './utils/share.js'  //注意路径是上一步新建文件的路径


import App from './App.vue'
export function createApp() {
  const app = createSSRApp(App)

  app.mixin(share)
  app.use(pinia)
  return {
    app,
  }
}
