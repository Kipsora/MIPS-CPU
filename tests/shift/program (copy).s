lui $2, 0x0404
ori $2, $2, 0x0404
ori $7, $0, 0x7
ori $5, $0, 0x5
ori $8, $0, 0x8
sync
sll $2, $2, 8
sllv $2, $2, $7
srl $2, $2, 8
srlv $2, $2, $5
nop
nop # FIXME: original is pref
sll $2, $2, 19
ssnop
sra $2, $2, 16
srav $2, $2, $8