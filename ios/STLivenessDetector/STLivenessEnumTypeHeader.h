//
//  STLivenessEnumTypeHeader.h
//  STLivenessEnumTypeHeader
//
//  Created by huoqiuliang on 2018/2/28.
//  Copyright © 2018年 sensetime. All rights reserved.
//

#ifndef STLivenessEnumTypeHeader_h
#define STLivenessEnumTypeHeader_h

/**
 *  STIDLiveness运行结果
 */
typedef NS_ENUM(NSInteger, STIDLivenessResult) {
    /** 正常运行 */
    STIDLiveness_OK = 0,
    /** 授权文件不合法 */
    STIDLiveness_E_LICENSE_INVALID = 1,
    /** 授权文件不存在 */
    STIDLiveness_E_LICENSE_FILE_NOT_FOUND = 2,
    /** 授权文件绑定包名错误 */
    STIDLiveness_E_LICENSE_BUNDLE_ID_INVALID = 3,
    /** 授权文件过期 */
    STIDLiveness_E_LICENSE_EXPIRE = 4,
    /** 授权文件与SDK版本不匹配 */
    STIDLiveness_E_LICENSE_VERSION_MISMATCH = 5,
    /** 授权文件不支持当前平台 */
    STIDLiveness_E_LICENSE_PLATFORM_NOT_SUPPORTED = 6,
    /** 模型文件不合法 */
    STIDLiveness_E_MODEL_INVALID = 7,
    /** DETECTION 模型文件不存在 */
    STIDLiveness_E_DETECTION_MODEL_FILE_NOT_FOUND = 8,
    /** 模型文件过期 */
    STIDLiveness_E_MODEL_EXPIRE = 9,
    /** 参数设置不合法 */
    STIDLiveness_E_INVALID_ARGUMENT = 10,
    /** 检测扫描超时 */
    STIDLiveness_E_TIMEOUT = 11,
    /** API账户信息错误。*/
    STIDLiveness_E_API_KEY_INVALID = 12,
    /** 服务器访问错误 */
    STIDLiveness_E_SERVER_ACCESS = 13,
    /** 服务器访问超时 */
    STIDLiveness_E_SERVER_TIMEOUT = 14,
    /** 调用API状态错误 */
    STIDLiveness_E_CALL_API_IN_WRONG_STATE = 15,
    /** 运行失败 */
    STIDLiveness_E_FAILED = 16,
    /** 授权文件能力不支持 */
    STIDLiveness_E_CAPABILITY_NOT_SUPPORTED = 17,
    /** ALIGNMENT 模型文件不存在 */
    STIDLiveness_E_ALIGNMENT_MODEL_FILE_NOT_FOUND = 18,
    /** FRAME_SELECTOR 模型文件不存在 */
    STIDLiveness_E_FRAME_SELECTOR_MODEL_FILE_NOT_FOUND = 19,
    /** FACE_QUALITY 模型文件不存在 */
    STIDLiveness_E_FACE_QUALITY_MODEL_FILE_NOT_FOUND = 20,
    /** ANTI_SPOOFING 模型文件不存在 */
    STIDLiveness_E_ANTI_SPOOFING_MODEL_FILE_NOT_FOUND = 21,
    /** Api key 或者 api secret 为空*/
    STIDLiveness_E_API_KEY_SECRET_NULL = 22,
    /** 活体检测未通过 */
    STIDLiveness_E_HACK = 23
};

/**
 *  设备错误的类型
 */
typedef NS_ENUM(NSUInteger, STIDLivenessDeveiceError) {
    /** 相机权限获取失败 */
    STIDLiveness_E_CAMERA = 0,
    /** 应用即将被挂起 */
    STIDLiveness_WILL_RESIGN_ACTIVE,
};

/**
 *  网络请求云端的详细状态码
 */
typedef NS_ENUM(NSUInteger, STIDLivenessCloudInternalCode) {
    /** defaul  */
    STIDLiveness_CLOUD_INTERNAL_DEFAULT = -1,
    /** success  */
    STIDLiveness_CLOUD_INTERNAL_SUCCESS = 1000,
    /** api_key值为空  */
    STIDLiveness_CLOUD_INTERNAL_API_KEY_MISSING = 9001,
    /** 无效的api_key */
    STIDLiveness_CLOUD_INTERNAL_INVALID_API_KEY = 9002,
    /** api_key被禁用 */
    STIDLiveness_CLOUD_INTERNAL_API_KEY_IS_DISABLED = 9003,
    /** api_key已过期   */
    STIDLiveness_CLOUD_INTERNAL_API_KEY_HAS_EXPIRED = 9004,
    /** 无该功能权限 */
    STIDLiveness_CLOUD_INTERNAL_PERMISSION_DENIED = 9005,
    /** bundle_id值为空 */
    STIDLiveness_CLOUD_INTERNAL_BUNDLE_ID_MISSING = 9006,
    /** bundle_id被禁用     */
    STIDLiveness_CLOUD_INTERNAL_BUNDLE_ID_IS_DISABLED = 9007,
    /** 每日调用已达限制  */
    STIDLiveness_CLOUD_INTERNAL_DAILY_RATE_LIMIT_EXCEEDED = 9008,
    /** 未传入应用签名  */
    STIDLiveness_CLOUD_INTERNAL_APP_SIGN_MISSING = 9009,
    /** 应用签名验证失败 */
    STIDLiveness_CLOUD_INTERNAL_INVALID_APP_SIGN = 9010,
    /** 数据一致性验证失败  */
    STIDLiveness_CLOUD_INTERNAL_INVALID_SIGNATURE = 9011,
    /** bundle_id验证失败 */
    STIDLiveness_CLOUD_INTERNAL_INVALID_BUNDLE_ID = 9012,
    /** 内部错误，请联系商汤支持人员 */
    STIDLiveness_CLOUD_INTERNAL_SENSETIME_ERROR = 9100,

};

#endif /* STLivenessEnumTypeHeader_h */
