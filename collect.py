#!/usr/bin/env python

from glob import glob
from os import makedirs
from os.path import basename, exists, join
from shutil import copy

if __name__=='__main__':

    event = 'NKT'
    #model = 's40rts_crust1.0'
    model = '1D_ak135f_no_mud'

    for src in ['Mrr', 'Mtt']:

       dir1 = join('_run', event, model, src, 'OUTPUT_FILES')
       dir2 = join('output', event, model)

       if not exists(dir1):
           raise Exception

       if exists(dir2):
           print('Directory already exists.')
       makedirs(dir2, exist_ok=True)

       for filename in glob(join(dir1, '*.sac')):

           filename = basename(filename)
           parts = filename.split('.')
           net, sta, loc = parts[0], parts[1], ''
           component = parts[2][-1]

           filename1 = filename
           filename2 = '.'.join([net, sta, loc, component, src, 'sac'])

           fullname1 = join(dir1, filename1)
           fullname2 = join(dir2, filename2)

           copy(fullname1, fullname2)

           print(fullname1, '\n', fullname2, '\n')

