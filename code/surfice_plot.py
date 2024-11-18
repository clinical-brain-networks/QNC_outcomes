'''
To run these, open surfice and copy/run into the code gui
Maybe need to update the paths appropriately.
'''
import gl

# response plot
gl.resetdefaults()
gl.meshload('BrainMesh_ICBM152.lh.mz3')
gl.nodeload(
    '/Users/lukeh/Documents/projects/QNC_BR/figures/TMS_coords_Response.node')
gl.shaderxray(1.0, 1.0)
gl.nodecolor('Inferno', 1)
gl.shaderambientocclusion(.40)
gl.savebmp(
    '/Users/lukeh/Documents/projects/QNC_BR/figures/TMS_coords_Response')

# tier plot
gl.resetdefaults()
gl.meshload('BrainMesh_ICBM152.lh.mz3')
gl.nodeload(
    '/Users/lukeh/Documents/projects/QNC_BR/figures/TMS_coords_Tier.node')
gl.shaderxray(1.0, 1.0)
gl.nodecolor('Inferno', 1)
gl.nodethresh(0, 3)
gl.shaderambientocclusion(.40)
gl.savebmp('/Users/lukeh/Documents/projects/QNC_BR/figures/TMS_coords_Tier')
