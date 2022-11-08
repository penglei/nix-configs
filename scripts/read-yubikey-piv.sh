slots=("9a" "9c" "9d" "9e" "82" "83" "84" "85" "86" "87" "88" "89" "8a" "8b" "8c" "8d" "8e" "8f" "90" "91" "92" "93" "94" "95" "f9")

for i in ${slots[@]}; do
	yubico-piv-tool -a read-certificate -s $i
	#ykman piv certificates export $i -
	ykman piv keys export $i -
done
