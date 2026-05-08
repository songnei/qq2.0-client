import { http } from '@kit.NetworkKit'
import { BASE_URL, Api } from './http/ApiConfig'
import { promptAction } from '@kit.ArkUI'
import router from '@ohos.router'

interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

interface HttpRequestHeader {
  'Content-Type': string
  'Authorization'?: string
}

interface LoginBody {
  account: string
  password: string
}

interface RegisterBody {
  phone: string
  code: string
  password: string
  nickname?: string
}

interface LoginData {
  token: string
  userId: string
  qqNumber: string
  nickname: string
  avatar: string
}

function getToken(): string {
  const cached = AppStorage.get<string>('token')
  return cached || ''
}

function setToken(token: string): void {
  AppStorage.setOrCreate<string>('token', token)
}

function clearToken(): void {
  AppStorage.setOrCreate<string>('token', '')
  AppStorage.setOrCreate<string>('userId', '')
  AppStorage.setOrCreate<string>('userQq', '')
  AppStorage.setOrCreate<string>('userNickname', '')
  AppStorage.setOrCreate<string>('userAvatar', '')
}

function saveLoginInfo(token: string, userId: string, qqNumber: string, nickname: string, avatar: string): void {
  setToken(token)
  AppStorage.setOrCreate<string>('userId', userId)
  AppStorage.setOrCreate<string>('userQq', qqNumber)
  AppStorage.setOrCreate<string>('userNickname', nickname)
  AppStorage.setOrCreate<string>('userAvatar', avatar)
}

function getUserId(): string {
  return AppStorage.get<string>('userId') || ''
}

async function request<T>(url: string, method: http.RequestMethod, body?: object): Promise<T> {
  const httpRequest = http.createHttp()
  try {
    const token = getToken()
    const noAuth: HttpRequestHeader = { 'Content-Type': 'application/json' }
    const withAuth: HttpRequestHeader = { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
    const headerVal: HttpRequestHeader = token.length > 0 ? withAuth : noAuth
    const options: http.HttpRequestOptions = {
      method: method,
      header: headerVal,
      readTimeout: 15000,
      connectTimeout: 10000
    }

    if (body && method !== http.RequestMethod.GET) {
      options.extraData = JSON.stringify(body)
    }

    const response = await httpRequest.request(BASE_URL + url, options)
    httpRequest.destroy()

    if (response.responseCode === 401) {
      clearToken()
      promptAction.showToast({ message: '登录已过期，请重新登录' })
      router.replaceUrl({ url: 'pages/LoginPage' })
      throw new Error('Unauthorized')
    }

    if (response.responseCode !== 200) {
      throw new Error('HTTP Error: ' + response.responseCode)
    }

    const result = JSON.parse(response.result as string) as ApiResponse<T>

    if (result.code !== 200) {
      throw new Error(result.message || '请求失败')
    }

    return result.data
  } catch (err) {
    httpRequest.destroy()
    if (err instanceof Error) {
      throw err
    }
    throw new Error(String(err))
  }
}

async function get<T>(url: string): Promise<T> {
  return request<T>(url, http.RequestMethod.GET)
}

async function post<T>(url: string, body?: object): Promise<T> {
  return request<T>(url, http.RequestMethod.POST, body)
}

async function put<T>(url: string, body?: object): Promise<T> {
  return request<T>(url, http.RequestMethod.PUT, body)
}

async function del<T>(url: string): Promise<T> {
  return request<T>(url, http.RequestMethod.DELETE)
}

async function sendSmsCode(phone: string, type: number): Promise<string> {
  const code = await post<string>(Api.AUTH_SMS + '?phone=' + phone + '&type=' + type)
  return code || ''
}

async function login(account: string, password: string): Promise<LoginData> {
  const loginBody: LoginBody = { account: account, password: password }
  const data = await post<LoginData>(Api.AUTH_LOGIN, loginBody)
  saveLoginInfo(
    data.token || '',
    data.userId?.toString() || '',
    data.qqNumber || '',
    data.nickname || '',
    data.avatar || ''
  )
  return data
}

async function register(phone: string, code: string, password: string, nickname?: string): Promise<LoginData> {
  const registerBody: RegisterBody = { phone: phone, code: code, password: password }
  if (nickname) {
    registerBody.nickname = nickname
  }
  const data = await post<LoginData>(Api.AUTH_REGISTER, registerBody)
  saveLoginInfo(
    data.token || '',
    data.userId?.toString() || '',
    data.qqNumber || '',
    data.nickname || '',
    data.avatar || ''
  )
  return data
}

async function logout(): Promise<void> {
  try {
    await post<void>(Api.AUTH_LOGOUT)
  } catch (_e) {
  }
  clearToken()
}

export {
  get,
  post,
  put,
  del,
  sendSmsCode,
  login,
  register,
  logout,
  getToken,
  setToken,
  clearToken,
  saveLoginInfo,
  getUserId,
  LoginBody,
  RegisterBody,
  LoginData,
  BASE_URL,
  Api
}
