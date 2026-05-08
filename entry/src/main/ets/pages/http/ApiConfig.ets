export const BASE_URL: string = 'http://10.160.56.122:8080'
export const WS_URL: string = 'ws://10.160.56.122:9090/ws'

export class Api {
  static readonly AUTH_SMS: string = '/api/auth/sms/send'
  static readonly AUTH_REGISTER: string = '/api/auth/register'
  static readonly AUTH_LOGIN: string = '/api/auth/login'
  static readonly AUTH_LOGOUT: string = '/api/auth/logout'
  static readonly AUTH_REFRESH: string = '/api/auth/refresh'

  static readonly USER_PROFILE: string = '/api/user/profile'
  static readonly USER_STATUS: string = '/api/user/status'
  static readonly USER_SEARCH: string = '/api/user/search'

  static readonly FRIEND_LIST: string = '/api/friend/list'
  static readonly FRIEND_LIST_GROUPED: string = '/api/friend/list/grouped'
  static readonly FRIEND_REQUEST: string = '/api/friend/request'
  static readonly FRIEND_REQUESTS: string = '/api/friend/requests'
  static readonly FRIEND_GROUPS: string = '/api/friend/group/list'

  static readonly conversationList: string = '/api/message/conversation/list'

  static readonly MSG_HISTORY: string = '/api/message/history'
  static readonly MSG_SEND: string = '/api/message/send'
  static readonly MSG_SEND_GROUP: string = '/api/message/send/group'
  static readonly MSG_MARK_READ: string = '/api/message/read'

  static readonly GROUP_CREATE: string = '/api/group/create'
  static readonly GROUP_LIST: string = '/api/group/list'
  static readonly GROUP_INVITE: string = '/api/group/'
  static readonly GROUP_INVITE_LIST: string = '/api/group/invite/list'
  static readonly GROUP_INVITE_ACCEPT: string = '/api/group/invite/'
  static readonly GROUP_INVITE_REJECT: string = '/api/group/invite/'

  static readonly SPACE_FEED: string = '/api/space/feed'
  static readonly SPACE_POST: string = '/api/space/post'
  static readonly SPACE_VISITORS: string = '/api/space/visitor'
  static readonly SPACE_MEMORY: string = '/api/space/memory'

  static readonly FILE_UPLOAD: string = '/api/file/upload'
  static readonly FILE_IMAGE: string = '/api/file/upload/image'
  static readonly FILE_VOICE: string = '/api/file/upload/voice'

  static userById(id: string): string {
    return `/api/user/${id}`
  }

  static friendAccept(id: number): string {
    return `/api/friend/request/${id}/accept`
  }

  static friendReject(id: number): string {
    return `/api/friend/request/${id}/reject`
  }

  static friendDelete(id: number): string {
    return `/api/friend/${id}`
  }

  static friendRemark(id: number): string {
    return `/api/friend/${id}/remark`
  }

  static friendBlock(id: number): string {
    return `/api/friend/${id}/block`
  }

  static friendSpecial(id: number): string {
    return `/api/friend/${id}/special`
  }

  static friendMoveGroup(id: number): string {
    return `/api/friend/${id}/group`
  }

  static conversationPin(id: number): string {
    return `/api/message/conversation/${id}/pin`
  }

  static conversationMute(id: number): string {
    return `/api/message/conversation/${id}/mute`
  }

  static conversationRead(id: number): string {
    return `/api/message/conversation/${id}/read`
  }

  static conversationDelete(id: number): string {
    return `/api/message/conversation/${id}`
  }

  static msgRecall(id: number): string {
    return `/api/message/recall/${id}`
  }

  static msgForward(id: number): string {
    return `/api/message/forward/${id}`
  }

  static msgFavorite(id: number): string {
    return `/api/message/favorite/${id}`
  }

  static groupDetail(id: number): string {
    return `/api/group/${id}`
  }

  static groupUpdate(id: number): string {
    return `/api/group/${id}`
  }

  static groupDelete(id: number): string {
    return `/api/group/${id}`
  }

  static groupJoin(id: number): string {
    return `/api/group/${id}/join`
  }

  static groupExit(id: number): string {
    return `/api/group/${id}/exit`
  }

  static groupInvite(id: number): string {
    return `/api/group/${id}/invite`
  }

  static groupKick(id: number, memberId: number): string {
    return `/api/group/${id}/member/${memberId}`
  }

  static groupMemberRole(id: number, memberId: number): string {
    return `/api/group/${id}/member/${memberId}/role`
  }

  static groupMemberMute(id: number, memberId: number): string {
    return `/api/group/${id}/member/${memberId}/mute`
  }

  static groupMuteAll(id: number): string {
    return `/api/group/${id}/mute-all`
  }

  static groupMembers(id: number): string {
    return `/api/group/${id}/member`
  }

  static groupAnnouncements(id: number): string {
    return `/api/group/${id}/announcement`
  }

  static groupCreateAnnouncement(id: number): string {
    return `/api/group/${id}/announcement`
  }

  static groupDeleteAnnouncement(id: number, aid: number): string {
    return `/api/group/${id}/announcement/${aid}`
  }

  static groupFiles(id: number): string {
    return `/api/group/${id}/file`
  }

  static groupUploadFile(id: number): string {
    return `/api/group/${id}/file`
  }

  static groupPolls(id: number): string {
    return `/api/group/${id}/poll`
  }

  static groupCreatePoll(id: number): string {
    return `/api/group/${id}/poll`
  }

  static groupPollVote(id: number, pid: number): string {
    return `/api/group/${id}/poll/${pid}/vote`
  }

  static spaceLike(id: number): string {
    return `/api/space/post/${id}/like`
  }

  static spaceComment(id: number): string {
    return `/api/space/post/${id}/comment`
  }

  static spaceDeletePost(id: number): string {
    return `/api/space/post/${id}`
  }

  static spaceDeleteComment(id: number): string {
    return `/api/space/comment/${id}`
  }

  static fileDownload(objectName: string): string {
    return `/api/file/download/${objectName}`
  }
}
