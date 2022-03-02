# Operating Systems Capstone 2022

| GitHub account name | Student ID | Name   |
| ------------------- | ---------- | ------ |
| cl3nn0              | 310551034  | 張逸軍  |

## How to build

### Get object file from source code
```bash
aarch64-unknown-linux-gnu-gcc -c a.S -o a.o
```

### Get elf from object file
```bash
aarch64-unknown-linux-gnu-ld -T linker.ld -o kernel8.elf a.o
```

### Get image file from elf
```bash
aarch64-unknown-linux-gnu-objcopy -O binary kernel8.elf kernel8.img
```

## Run on QEMU
```bash
qemu-system-aarch64 -M raspi3 -kernel kernel8.img -display none -d in_asm
```
