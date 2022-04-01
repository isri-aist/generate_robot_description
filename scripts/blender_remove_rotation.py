import os

import bpy
import sys
import mathutils

argv = sys.argv
argv = argv[argv.index("--") + 1:] # get all args after "--"

fbx_in = argv[0]
fbx_out = argv[1]

bpy.ops.wm.collada_import(filepath = fbx_in, import_units = True)
bpy.ops.object.mode_set(mode = 'OBJECT')

objects = bpy.data.objects
for obj in objects:
  obj.select_set(False)

def remove_rotation(obj):
    obj.rotation_euler[0] = 0.0
    obj.rotation_euler[1] = 0.0
    obj.rotation_euler[2] = 0.0

for obj in filter(lambda o: (o.type == 'MESH' or o.type == 'EMPTY'), objects):
    remove_rotation(obj)

bpy.ops.wm.collada_export(filepath = fbx_out)
