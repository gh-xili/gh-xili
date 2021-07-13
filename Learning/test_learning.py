from string import Template
import os
import argparse

def test(_input):
    """
    Here is doc string?
    """
    
    print ("Input parameter is: " + _input)
    b = bytes([0x41, 0x42, 0x43, 0x44])
    s = "This is a string"
    print(b.decode('utf-8')+s)
    A="CN"
    B="US"

    name_dic = {
        "A": "China",
        "B": "USA"
    }

    print(tem2.substitute(name_dic))

def get_args():
    """
    Parse command line arguments and return argument object.
    :return: object
    """
    parser = argparse.ArgumentParser(description='"Some Input argu for Generate Fragsize Distribution.')
    parser.add_argument('-i', '--input', required=True, action='store',
                        help="Input File of .molucule.table")
    return parser.parse_args()

def run():
    # get args
    
   # args = get_args()
    print (test.__doc__)
    #test(args.input)
    
    return None

if __name__ == "__main__":
    # use this section to either run unit tests or execute as command line utility 
    run()