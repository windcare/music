package controller

const (
	OK                      = iota // 0
	InvalidToken            = iota // 1
	EmptyToken              = iota // 2
	LoginPasswordError      = iota // 3
	LoginInvalidUserName    = iota // 4
	LoginDatabaseError      = iota // 5
	RegisterInvalidUserName = iota // 6
	RegisterShortPassword   = iota // 7
	RegisterDatabaseError   = iota // 8
	DatabaseError           = iota // 9
	InvalidParam            = iota // 10
	HeatBeatSingal          = iota
)

const HttpReadSize = 4 * 1024
