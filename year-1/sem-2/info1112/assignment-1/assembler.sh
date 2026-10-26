#!/bin/bash

int_to_byte() {
	# Converts a hex number to the corresponding byte
	
	printf -v byte "\\%o" $1
	printf "$byte"
}

# Check arguments

if [ $# -eq 0 ]; then
	echo "usage: no argument is provided"
	exit 1
fi

if [ $# -gt 1 ]; then
	echo "usage: more than one arguments are provided"
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "usage: input is not a file or it does not exist"
	exit 1
fi

# Read from file

file=$1

if [[ ! "$file" =~ \.vsc$ ]]; then
	echo "usage: input does not have the extension .vsc"
	exit 1
fi

# Read lines from file

sed -i 's/\r$//' $file # Remove carriage returns from CRLF

read -d "\n" -r -a lines < $file

if [ "${#lines[@]}" -eq 0 ]; then
	echo "usage: the file is empty - no .bin file is produced"
	exit 1
fi

# Check instruction pointer

instruction_ptr=${lines[0]}

if [ "$instruction_ptr" -ne 0 ] && [ "$instruction_ptr" -ne 2 ]; then
	echo "usage: invalid instruction pointer $instruction_ptr"
	exit 1
fi

# Expect a QUIT program if instruction pointer is zero

if [ "$instruction_ptr" -eq 0 ]; then
	if [[ ! "${lines[1]}" = 'QUIT,0,0' ]]; then
		echo "usage: expected 'QUIT,0,0' instead of '${lines[1]}'"
		exit 1
	fi

	printf "\x00\x20\x00" > ${file%.*}.bin

	echo "It is a QUIT program"
	echo "The content of the .bin file is"
	echo 20
	echo 00

	exit 0
fi

bin_output=() # Unencoded bytes in hex

# Check given memory values

if [ "${#lines[@]}" -lt 3 ]; then
	echo "usage: memory must be initialised"
	exit 1
fi

for val in ${lines[@]:1:2}; do
	if [[ ! "$val" =~ ^[0-9]+$ ]]; then
		echo "usage: memory value must be an integer"
		exit 1
	fi

	if [ "$val" -lt 0 ] || [ "$val" -gt 127 ]; then
		echo "usage: memory value outside of range [0, 127]"
		exit 1
	fi
done

# Add memory values to output

bin_output[0]=${lines[1]}
bin_output[1]=${lines[2]}

# Parse instructions

for ((i = 3; i < ${#lines[@]}; i += 1)); do
	# Maximum instruction length of eleven
	
	if [ "${#lines[i]}" -gt 11 ]; then
		echo "usage: line $i cannot be more than 11 characters long"
		exit 1
	fi


	# Read arguments
	
	IFS=, read -a args <<< ${lines[i]}
	
	cmd=${args[0]}
	reg=${args[1]}
	addr=${args[2]}

	# Check arguments
	
	if [[ ! "$reg" =~ ^[0-9]+$ ]] || [ "$reg" -lt 0 ] || [ "$reg" -gt 3 ]; then
		echo "usage: argument 1 in line $i must be a number in the range [0, 3]"
		exit 1
	fi

	if [[ ! "$addr" =~ ^[0-9]+$ ]] || [ "$addr" -lt 0 ] || [ "$addr" -gt 255 ]; then
		echo "usage: argument 2 in line $i must be a number in the range [0, 255]"
		exit 1
	fi

	reg=$((reg))
	addr=$((addr))

	# Require memory arguments of PRINT to be zero
	
	if [ "$cmd" = 'PRINT' ] && [ "$addr" -ne 0 ]; then
		echo "usage: memory argument of PRINT must be zero"
		exit 1
	fi

	# Set opcode based on command
	
	opcode=$reg
	
	if [ "$cmd" = 'LOAD' ]; then
		((opcode += 4))
	elif [ "$cmd" = 'STORE' ]; then
		((opcode += 8))
	elif [ "$cmd" = 'ADD' ]; then
		((opcode += 12))
	elif [ "$cmd" = 'SUB' ]; then
		((opcode += 16))
	elif [ "$cmd" = 'QUIT' ]; then
		((opcode += 32))
	elif [ "$cmd" = 'PRINT' ]; then
		((opcode += 36))
	else
		echo "usage: invalid command '$cmd'"
		exit 1
	fi

	bin_output+=($opcode $addr)
	
	# Quit after max of 100 instructions
	
	if [ "$i" -eq 102 ] || [ "$i" -eq "$((${#lines[@]} - 1))" ]; then
		# Require QUIT statement for final instruction
		
		if [ ${lines[i]} = 'QUIT,0,0' ]; then
			break		
	 	fi

		echo "usage: final instruction must be QUIT,0,0"
		exit 1
	fi

	# Stop processing after QUIT instruction
	
	if [ "$cmd" = 'QUIT' ]; then
		if [ "$reg" -eq 0 ] && [ "$addr" -eq 0 ]; then
			break
		fi

		echo "usage: arguments of QUIT must both be zero"
		exit 1
	fi
done

# Write bytes to file 

bin_file="${file%.vsc}.bin"

echo -n > $bin_file

for val in ${bin_output[@]}; do
	(int_to_byte $val) >> $bin_file
done

# Print to stdout

echo "It is an ADD/SUB program"
echo "The content of the .bin file is"

xxd -p -c1 $bin_file

