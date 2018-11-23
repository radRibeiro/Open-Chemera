import lxml.etree as ET
import math
import sys
# Range for float variables
def frange(x, y, jump):
  while x < y:
    yield x
    x += jump
# Implementation of the spiral function
def points_on_sphere(number_of_points):
    """
    Creates a list of number_of_points points using the spiral method.
    """
    points = []
    increment = math.pi * (3. - math.sqrt(5.))
    offset = 2./number_of_points
    for n in range(number_of_points):
        y = n * offset - 1.0 + (offset / 2.0)
        r = math.sqrt(1 - y*y)
        phi = n * increment
        points.append([math.cos(phi)*r, y, math.sin(phi)*r])
    return points
    
print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv[7])
# filename cube/sphere radius size
# EX: dummyJobCreator.py probe sphere 500 1.5 target sphere 150 1.5 1000 500
#     dummyJobCreator.py probe cube 5 1.5 target cube 8 1.5
#     dummyJobCreator.py target sphere 3375 1.0 probe sphere 1728 1.0
#Sphere generation src: http://cubo2.net/blog/category/python/
if len(sys.argv) < 2 : 
	print 'HELP'
	print '<filename probe cube/sphere cubeSize/spherePoints atomRadius target cube/sphere cubeSize/spherePoints atomRadius rotations minOverlap>'
else : 
	root = ET.Element("Orders", Version = "1")
	doc = ET.SubElement(root, "DockRun")
	stats = ET.SubElement(doc,"Stats")
	dtc = ET.SubElement(stats,"DigitizationTickCount").text = str(0)
	ctc = ET.SubElement(stats,"ConstraintsTickCount").text = str(0)
	dmtc = ET.SubElement(stats,"DomainTickCount").text = str(0)
	stc = ET.SubElement(stats,"ScoringTickCount").text = str(0)
	tottc = ET.SubElement(stats,"TotalTickCount").text = str(0)
	testedtc = ET.SubElement(stats,"TestedModelsCount").text = str(0)
	stc = ET.SubElement(stats,"InsertedModelsCount").text = str(0)
	dckParameters = ET.SubElement(doc,"DockParameters")
	targetFile = ET.SubElement(dckParameters,"TargetFile").text = "/home/ricardoribeiro/.config/oclibrary/monomers/ARG.pdb"
	probeFile = ET.SubElement(dckParameters,"ProbeFile").text = "/home/ricardoribeiro/.config/oclibrary/monomers/ALA.pdb"
	res = ET.SubElement(dckParameters,"Resolution").text = str(1.00)
	addedRadius = ET.SubElement(dckParameters,"AddedRadius").text = str(1.35)
	scndSaves = ET.SubElement(dckParameters,"SecondsBetweenSaves").text = str(1000)
	completedRotations = ET.SubElement(dckParameters,"CompletedRotations").text = str(0)
	totalRotations = ET.SubElement(dckParameters,"TotalRotations").text = sys.argv[10]
	target = ET.SubElement(doc, "Target")
	if sys.argv[3] == "cube":   
         for i in frange(-(float(sys.argv[4])+1)/2,(float(sys.argv[4])+1)/2,float(sys.argv[5])):
             for j in frange(-(float(sys.argv[4])+1)/2,(float(sys.argv[4])+1)/2,float(sys.argv[5])):
                 for k in frange(-(float(sys.argv[4])+1)/2,(float(sys.argv[4])+1)/2,float(sys.argv[5])):
                     x = float(i)
                     y = float(j)
                     z = float(k)
                     r = float(sys.argv[5])
                     atom = ET.SubElement(target, "Atom", X = str(round(x,3)),Y = str(round(y,3)),Z = str(z))
                     atom.set("R",str(r))
	if sys.argv[3] == "sphere":
             atoms = points_on_sphere(int(sys.argv[4]))
             r = float(sys.argv[5])
             for i in range(len(atoms)):
                 atom = ET.SubElement(target, "Atom", X = str(round(atoms[i][0],2)),
                                      Y = str(round(atoms[i][1],3)),Z = str(round(atoms[i][2],3)))
                 atom.set("R",str(r))
	probe = ET.SubElement(doc,"Probe")
	if sys.argv[7] == "cube":
         for l in frange(-(float(sys.argv[8])+1)/2,(float(sys.argv[8])+1)/2,float(sys.argv[9])):
             for m in frange(-(float(sys.argv[8])+1)/2,(float(sys.argv[8])+1)/2,float(sys.argv[9])):
                 for n in frange(-(float(sys.argv[8])+1)/2,(float(sys.argv[8])+1)/2,float(sys.argv[9])):
                     x = float(l+1)
                     y = float(m+1)
                     z = float(n+1)
                     r = float(sys.argv[9])
                     atom = ET.SubElement(probe, "Atom",X = str(round(x,3)),Y = str(round(y,3)),Z = str(z))
                     atom.set("R",str(r))
	if sys.argv[7] == "sphere":
             atoms = points_on_sphere(int(sys.argv[8]))
             r = float(sys.argv[5])
             for i in range(len(atoms)):
                  atom = ET.SubElement(probe , "Atom", X = str(round(atoms[i][0]+2,2)),
                                      Y = str(round(atoms[i][1]+2,3)),Z = str(round(atoms[i][2]+2,3)))
                  atom.set("R",str(r))
	axes = ET.SubElement(doc,"Axes")
	axis1 = ET.SubElement(axes,"Axis",X ="0.000",Y="0.000",Z="1.000")
	axis2 = ET.SubElement(axes,"Axis",X="0.388",Y="0.919",Z="0.063")
	rotations = ET.SubElement(doc,"Rotations")
	rotation1 = ET.SubElement(rotations,"Rotation",r="1.000")
	rotation1.set("i","0.000")
	rotation1.set("j","0.000")
	rotation1.set("k","0.000")
	rotation1.set("ix","0")
	jcs = ET.SubElement(doc,"JointConstraintSet",Name = "Unconstrained", NumModels = "5000")
	jcs.set("MinOverlap",sys.argv[11])
	tree = ET.ElementTree(root)
	fileString = "jobFiles/{}{}dummyJobP{}T{}R{}O{}.xml"
	tree.write(fileString.format(sys.argv[3],sys.argv[7],sys.argv[4]
     ,sys.argv[8],sys.argv[10],sys.argv[11]))
