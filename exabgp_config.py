#!/usr/bin/env python

import sys

config_path = sys.argv[1]
address = sys.argv[2]
prefix_count = int(sys.argv[3]) - 1


fd = open(config_path, 'w')
fd.write('''
neighbor {} {{
  router-id 172.17.0.1;
  local-address 127.0.0.1;
  local-as 100;
  peer-as 100;

  capability {{
    graceful-restart;
  }}

  announce {{
    ipv4 {{
'''.format(address))

while prefix_count >= 0:
    net = (prefix_count / 254) + 1
    subnet = (prefix_count % 254) + 1
    prefix_count -= 1

    fd.write('      unicast 10.{}.{}.0/24 next-hop 172.17.0.1;\n'.format(net, subnet))

fd.write('''    }
  }
}
''')

exit(0)
