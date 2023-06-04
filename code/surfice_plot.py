import gl

# response plot
gl.resetdefaults()
gl.meshload('BrainMesh_ICBM152.lh.mz3')
gl.nodeload(
    '/Users/lukehearne/Documents/projects/QNC_BR/code/TMS_coords_Response.node')
gl.shaderxray(1.0, 1.0)
gl.nodecolor('Inferno', 1)
gl.shaderambientocclusion(.40)
gl.savebmp(
    '/Users/lukehearne/Documents/projects/QNC_BR/figures/TMS_coords_Response')

# tier plot
gl.resetdefaults()
gl.meshload('BrainMesh_ICBM152.lh.mz3')
gl.nodeload(
    '/Users/lukehearne/Documents/projects/QNC_BR/code/TMS_coords_Tier.node')
gl.shaderxray(1.0, 1.0)
gl.nodecolor('Inferno', 1)
gl.nodethresh(0, 3)
gl.shaderambientocclusion(.40)
gl.savebmp('/Users/lukehearne/Documents/projects/QNC_BR/figures/TMS_coords_Tier')
