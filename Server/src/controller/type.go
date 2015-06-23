package controller

type BasicMessage struct {
	Action string
}

type RegisterParam struct {
	Username string
	Password string
	Sex      string
	Age      int
}

type RegisterMessage struct {
	*BasicMessage
	*RegisterParam
}
