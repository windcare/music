package algorithm

type Matrix struct {
	Row    uint
	Col    uint
	matrix [][]float64
}

func NewMatrix(row, col uint) *Matrix {
	return &Matrix{Row: row, Col: col}
}

func (this *Matrix) SetNumber(row, col uint, number float64) {
	if row < this.Row && col < this.Col {
		if this.matrix != nil {
			this.matrix[row][col] = number
		}
	}
}
