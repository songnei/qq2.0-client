import { get, post, put, Api } from './HttpRequest'

export class UserStatusInfo {
  icon: string = '🟢'
  name: string = '在线'
}

export class ChatContactInfo {
  name: string = ''
  avatar: string = ''
  isGroup: boolean = false
  isAdmin: boolean = false
}

export class SearchDataItem {
  type: string = ''
  title: string = ''
  subtitle: string = ''
  avatar: string = ''
  extra: string = ''
}

export class UserProfile {
  id: number = 0
  qqNumber: string = ''
  phone: string = ''
  nickname: string = ''
  avatar: string = '🐶'
  gender: number = 0
  birthday: string = ''
  location: string = ''
  school: string = ''
  signature: string = ''
  status: number = 1
  statusIcon: string = '🟢'
  vipLevel: number = 0
  online: boolean = true
}

const STATUS_ICON_MAP: Record<string, string> = {
  '在线': '🟢',
  '离开': '🕐  ',
  '忙碌': '⛔',
  '请勿打扰': '🚫',
  '隐身': '⚪',
  'Q我吧': '😊',
  '我的电量': '🔋',
  '听歌中': '🎧',
  '出去浪': '🐧',
  '去旅行': '🧳',
  '被掏空': '😵',
  '运动中': '🏃',
  '今日天气': '☁️',
  '我crush了': '💗',
  '爱你': '🥰'
}

export function getStatusIcon(statusName: string): string {
  return STATUS_ICON_MAP[statusName] || '🟢'
}

const STATUS_CODE_MAP: Record<string, number> = {
  '在线': 1,
  '离开': 2,
  '忙碌': 3,
  '请勿打扰': 4,
  '隐身': 5
}

export async function updateStatusToServer(icon: string, name: string): Promise<boolean> {
  try {
    const statusCode = STATUS_CODE_MAP[name] || 1
    await put<void>(Api.USER_STATUS + '?status=' + statusCode + '&statusIcon=' + encodeURIComponent(icon))
    return true
  } catch (_e) {
    return false
  }
}

export async function loadUserProfile(): Promise<UserProfile | null> {
  try {
    const profile = await get<UserProfile>(Api.USER_PROFILE)
    if (profile) {
      AppStorage.setOrCreate<string>('userNickname', profile.nickname || '')
      AppStorage.setOrCreate<string>('userAvatar', profile.avatar || '🐶')
      AppStorage.setOrCreate<string>('userQq', profile.qqNumber || '')
      AppStorage.setOrCreate<string>('userStatusIcon', profile.statusIcon || '🟢')
    }
    return profile
  } catch (_e) {
    return null
  }
}
