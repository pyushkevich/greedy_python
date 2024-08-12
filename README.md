Python wrappers for PICSL GreedyReg Image Registration Tool
===========================================================

This project provides a Python interface for the [**Greedy** tool](https://github.com/pyushkevich/greedy) from the [Penn Image Computing and Science Laboratory](picsl.upenn.edu), developers of [ITK-SNAP](itksnap.org).

**Greedy** is a fast tool for affine and deformable registration of 3D (and 2D) medical images. Please see [Greedy Documentation](https://greedy.readthedocs.io/en/latest/) for complete documentation.

This project makes it possible to interface with **Greedy** from Python code. You can execute registration pipelines as you would on the command line, and you pass [SimpleITK](https://simpleitk.org/) image objects to and from **Greedy** as inputs or outputs.

Quick Start
-----------
Install the package:

```sh
pip install picsl_greedy
```

Download a pair of images and a binary mask to experiment with

```sh
DATAURL=https://github.com/pyushkevich/greedy/raw/master/testing/data
curl -L $DATAURL/phantom01_fixed.nii.gz -o phantom01_fixed.nii.gz
curl -L $DATAURL/phantom01_moving.nii.gz -o phantom01_moving.nii.gz
curl -L $DATAURL/phantom01_mask.nii.gz -o phantom01_mask.nii.gz
```

Perform rigid registration in Python

```python
from picsl_greedy import Greedy3D

g = Greedy3D()

# Perform rigid registration
g.execute('-i phantom01_fixed.nii.gz phantom01_moving.nii.gz '
          '-gm phantom01_mask.nii.gz '
          '-a -dof 6 -n 40x10 -m NMI '
          '-o phantom01_rigid.mat')
          
# Apply rigid transform to moving image
g.execute('-rf phantom01_fixed.nii.gz '
          '-rm phantom01_moving.nii.gz phantom01_resliced.nii.gz '
          '-r phantom01_rigid.mat')
```

SimpleITK Interface
-------------------
You can read/write images from disk using the command line options passed to the `execute` command. But if you want to mix Python-based image processing pipelines and **Greedy** pipelines, using the disk to store images creates unnecessary overhead. Instead, it is possible to pass [SimpleITK](https://simpleitk.org/) to **Greedy** as image inputs and outputs. It is also possible to pass NumPy arrays as rigid and affine transformations.

To pass objects already available in your Python environment, you can use arbitrary strings instead of filenames in the **Greedy** command, and then use keyword arguments to associate these strings with SimpleITK images or NumPy arrays:

```python
img_fixed = sitk.ReadImage('phantom01_fixed.nii.gz')
img_moving = sitk.ReadImage('phantom01_moving.nii.gz')
g.execute('-i my_fixed my_moving '
          '-a -dof 6 -n 40x10 -m NMI '
          '-o phantom01_rigid.mat', 
          my_fixed = img_fixed, my_moving = img_moving)
```

Conversely, to retrieve an image or transform output by **Greedy** into the Python envirnonment, you can also replace the filename by a string, and use keyword arguments to assign `None` to that string. You can then retrieve the output using the `[]` operator:

```python
g.execute('-i phantom01_fixed.nii.gz phantom01_moving.nii.gz '
          '-gm phantom01_mask.nii.gz '
          '-a -dof 6 -n 40x10 -m NMI '
          '-o my_rigid',
          my_rigid=None)
          
mat_rigid = g['my_rigid']
```

The example below performs affine and deformable registration and then applies reslicing to the moving image without having **Greedy** write any files to disk.

```python
from picsl_greedy import Greedy3D
import SimpleITK as sitk
import numpy as np

# Load the images
img_fixed = sitk.ReadImage('phantom01_fixed.nii.gz')
img_moving = sitk.ReadImage('phantom01_moving.nii.gz')
img_mask = sitk.ReadImage('phantom01_mask.nii.gz')

g = Greedy3D()

# Perform affine registration
g.execute('-i my_fixed my_moving '
          '-a -dof 6 -n 40x10 -m NMI '
          '-o my_affine',
          my_fixed = img_fixed, my_moving = img_moving, my_mask = img_mask,
          my_affine = None)

# Report the determinant of the affine transform
print('The affine transform determinant is ', np.linalg.det(g['my_affine']))

# Perform deformable registration
g.execute('-i my_fixed my_moving '
          '-it my_affine -n 40x10 -m NCC 2x2x2 -s 2.0vox 0.5vox '
          '-o my_warp',
          my_warp = None)

# Apply the transforms to the moving image
g.execute('-rf my_fixed -rm my_moving my_resliced '
          '-r my_warp my_affine',
          my_resliced = None)

# Save the resliced image
sitk.WriteImage(g['my_resliced'], 'phantom01_warped.nii.gz')
```

Metric Log
----------
If you would like to access the optimization metric value across iterations, use the method `metric_log()`.

```python
from picsl_greedy import Greedy3D
import SimpleITK as sitk
import numpy as np
import matplotlib.pyplot as plt

# Load the images
img_fixed = sitk.ReadImage('phantom01_fixed.nii.gz')
img_moving = sitk.ReadImage('phantom01_moving.nii.gz')
img_mask = sitk.ReadImage('phantom01_mask.nii.gz')

g = Greedy3D()

# Perform affine registration
g.execute('-i my_fixed my_moving '
          '-a -dof 6 -n 40x10 -m NMI '
          '-o my_affine',
          my_fixed = img_fixed, my_moving = img_moving, my_mask = img_mask,
          my_affine = None)

# Report metric value
ml = g.metric_log()
plt.plot(ml[0]["TotalPerPixelMetric"], label='Coarse')
plt.plot(ml[1]["TotalPerPixelMetric"], label='Fine')
plt.legend()
plt.title('Metric value')
plt.savefig('metric.png')
```
