from string import Template

def main():
    b = bytes([0x41, 0x42, 0x43, 0x44])
    s = "This is a string"
    #print(b.decode('utf-8')+s)

    A="CN"
    B="US"

    str1 = "From {0} to {1}".format(A, B)
    print(str1)

    tem2= Template("From ${A} to ${B}")
    str2 = tem2.substitute(A=A, B=B)
    print(str2)

    name_dic = {
        "A": "China",
        "B": "USA"
    }

    print(tem2.substitute(name_dic))

if __name__ == "__main__":
    main()