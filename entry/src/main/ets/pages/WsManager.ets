import { webSocket } from '@kit.NetworkKit'
import { WS_URL } from './http/ApiConfig'
import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'

interface WsMessage {
  msgId?: number
  type?: number
  senderId?: number
  receiverId?: number
  groupId?: number
  content?: string
  msgType?: string
  timestamp?: number
  extra?: object
}

let wsInstance: webSocket.WebSocket | null = null
let isConnected: boolean = false
let heartbeatTimer: number = -1
let reconnectTimer: number = -1
let reconnectDelay: number = 1000

function getAuthMessage(): string {
  const userId = AppStorage.get<string>('userId') || '0'
  const msg: WsMessage = {
    type: 1,
    senderId: Number(userId),
    timestamp: Date.now()
  }
  return JSON.stringify(msg)
}

function handleMessage(data: string): void {
  let msg: WsMessage
  try {
    msg = JSON.parse(data) as WsMessage
  } catch (_e) {
    return
  }

  const msgType = msg.type
  if (msgType === undefined || msgType === null) return

  if (msgType === 2) {
    startHeartbeat()
    return
  }

  if (msgType === 3) {
    return
  }

  if (msgType === 51 || msgType === 52) {
    AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
    return
  }

  if (msgType === 99) {
    disconnect()
    AppStorage.setOrCreate<string>('token', '')
    AppStorage.setOrCreate<string>('userId', '')
    AppStorage.setOrCreate<string>('avatar', '')
    promptAction.showToast({ message: '您的账号已在其他设备登录' })
    router.replaceUrl({ url: 'pages/LoginPage' })
    return
  }

  if (msgType === 10 || msgType === 20) {
    AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
    return
  }
}

function startHeartbeat(): void {
  stopHeartbeat()
  heartbeatTimer = setInterval(() => {
    if (wsInstance !== null && isConnected) {
      const heartbeat: WsMessage = {
        type: 3,
        timestamp: Date.now()
      }
      wsInstance.send(JSON.stringify(heartbeat), (err) => {
        if (err) {
          isConnected = false
          stopHeartbeat()
          scheduleReconnect()
        }
      })
    }
  }, 30000)
}

function stopHeartbeat(): void {
  if (heartbeatTimer >= 0) {
    clearInterval(heartbeatTimer)
    heartbeatTimer = -1
  }
}

function scheduleReconnect(): void {
  if (reconnectTimer >= 0) return
  reconnectTimer = setTimeout(() => {
    reconnectTimer = -1
    connectWs()
  }, reconnectDelay)
  reconnectDelay = Math.min(reconnectDelay * 2, 30000)
}

function connectWs(): void {
  const userId = AppStorage.get<string>('userId') || ''
  if (userId.length === 0) return

  if (wsInstance !== null) {
    try {
      wsInstance.close((err) => {
        if (err) {
        }
      })
    } catch (_e) {
    }
    wsInstance = null
  }

  wsInstance = webSocket.createWebSocket()

  wsInstance.connect(WS_URL, (err) => {
    if (err) {
      isConnected = false
      scheduleReconnect()
      return
    }

    isConnected = true
    reconnectDelay = 1000

    wsInstance!.on('message', (_err, data) => {
      if (_err) return
      if (typeof data === 'string') {
        handleMessage(data)
      }
    })

    wsInstance!.on('close', () => {
      isConnected = false
      stopHeartbeat()
      wsInstance = null
      scheduleReconnect()
    })

    wsInstance!.on('error', () => {
      isConnected = false
      stopHeartbeat()
    })

    const authMsg = getAuthMessage()
    wsInstance!.send(authMsg, (_err) => {
      if (_err) {
      }
    })
  })
}

function connect(): void {
  if (isConnected && wsInstance !== null) return
  connectWs()
}

function disconnect(): void {
  stopHeartbeat()
  if (reconnectTimer >= 0) {
    clearTimeout(reconnectTimer)
    reconnectTimer = -1
  }
  reconnectDelay = 1000
  if (wsInstance !== null) {
    try {
      wsInstance.close((_err) => {
      })
    } catch (_e) {
    }
    wsInstance = null
  }
  isConnected = false
}

function getConnected(): boolean {
  return isConnected
}

export {
  connect,
  disconnect,
  getConnected
}
