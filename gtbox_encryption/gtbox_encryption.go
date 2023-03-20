/*
Package gtbox_encryption 加密库
*/
package gtbox_encryption

/*
#cgo CFLAGS: -I../libs/gtgo
#cgo LDFLAGS: -L../libs/gtgo -lgtgo
#include "gtgo.h"
*/
import "C"

import (
	"crypto/md5"
	"encoding/hex"
	"unsafe"
)

// GTMD5Encoding MD5加密
func GTMD5Encoding(str string) string {
	h := md5.New()
	h.Write([]byte(str))
	return hex.EncodeToString(h.Sum(nil))
}

// GTEncryptionGo 自定义加密
func GTEncryptionGo(srcString string, keyString string) (resultStr string) {

	srcCasting := C.CString(srcString)
	resultMemSize := C.strlen(srcCasting) * 2

	CStr := (*C.char)(unsafe.Pointer(C.malloc(resultMemSize + 8 + 2)))
	C.memset(unsafe.Pointer(CStr), 0, resultMemSize+8+2)
	C.GT_encryptionStr(srcCasting, CStr, C.CString(keyString))

	retStr := C.GoString(CStr)
	C.free(unsafe.Pointer(CStr))

	return retStr
}

// GTDecryptionGo 自定义解密
func GTDecryptionGo(srcString string, keyString string) (resultStr string) {

	srcCasting := C.CString(srcString)
	resultMemSize := C.strlen(srcCasting) * 2

	CStr := (*C.char)(unsafe.Pointer(C.malloc(resultMemSize)))
	C.memset(unsafe.Pointer(CStr), 0, resultMemSize)
	C.GT_decryptionStr(srcCasting, CStr, C.CString(keyString))

	retStr := C.GoString(CStr)
	C.free(unsafe.Pointer(CStr))

	return retStr
}

// GTEncryptionGoReturnStringLength 自定义加密,并返回长度
func GTEncryptionGoReturnStringLength(srcString string, keyString string) (resultStr string, stringLength int) {

	srcCasting := C.CString(srcString)
	resultMemSize := C.strlen(srcCasting) * 2

	CStr := (*C.char)(unsafe.Pointer(C.malloc(resultMemSize + 8 + 2)))
	C.memset(unsafe.Pointer(CStr), 0, resultMemSize+8+2)
	C.GT_encryptionStr(srcCasting, CStr, C.CString(keyString))

	retStr := C.GoString(CStr)
	C.free(unsafe.Pointer(CStr))

	return retStr, int(C.strlen(retStr))
}

// GTDecryptionGoWithLength 自定义解密,传入长度
func GTDecryptionGoWithLength(srcString string, keyString string, stringLength int) (resultStr string) {
	srcCasting := C.CString(srcString)

	CStr := (*C.char)(unsafe.Pointer(C.malloc(stringLength)))
	C.memset(unsafe.Pointer(CStr), 0, stringLength)
	C.GT_decryptionStr(srcCasting, CStr, C.CString(keyString))

	retStr := C.GoString(CStr)
	C.free(unsafe.Pointer(CStr))

	return retStr
}
