(* ::Package:: *)

(* ::Title:: *)
(*DTITools MaskingTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["DTITools`MaskingTools`"];
$ContextPath=Union[$ContextPath,System`$DTIToolsContextPaths];

Unprotect @@ Names["DTITools`MaskingTools`*"];
ClearAll @@ Names["DTITools`MaskingTools`*"];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


Mask::usage =
"Mask[data,tresh min]creates a mask which selects only data above the treshlow value.
Mask[data,{tresh min,tresh max}] creates a mask which selects data between the tresh min and tresh max value."

MaskBin::usage = 
"MaskBin[data] creates a datamask from the given data."

SmartMask::usage = 
"SmartMask[input, mask] crates a smart mask of input based on mask."

SmartMask2::usage = 
"SmartMask2[input] crates a smart mask of input based.
SmartMask2[input, mask] crates a smart mask of input based on mask."

GetMaskData::usage =
"GetMaskData[data, mask] retruns the data selected by the mask as a single list for each image."

ROIMask::usage = 
"ROIMask[maskdim, {name->{{{x,y},slice}..}..}] crates mask from coordinates x and y at slice. \
maskdim is the dimensions of the output {zout,xout,yout}."

GofImport::usage = 
"GofImport[file] imports *.gof file to mathematica expresssion" 

ReadGof::usage = 
"ReadGof[file.gof, T1.dcm] imports the gof file to a format that can be used in ROIMask.
ReadGof[{file1.gof, file2.gof, ..}, T1.dcm] imports the gof files to a format that can be used in ROIMask.
ReadGof[{file1.gof, file2.gof, ..}, {T1-1.dcm, T1-2.dcm, ..}] imports the gof files to a format that can be used in ROIMask,\
where each .gof file correstponds to a different T1 file."

ReadROI::usage = 
"ReadROI[file, voxel, dim] imports *.gof file to format that can be used for ROImask (better use ReadGof).
ReadROI[filename, voxel, dim, off] imports *.gof file to format that can be used for ROImask using offset off (imagePosition dicom header)."

MaskDTIdata::usage =
"MaskDTIdata[data, mask] aplies a mask to a DTI dataset."

MaskTensdata::usage =
"MaskTensdata[data, mask] aplies a mask a tensor."

SmoothMask::usage = 
"SmoothMask[mask] generates one clean masked volume form a noisy mask.
SmoothMask[mask, int] higher number of int increases the maks size, default value is 2."

HomoginizeData::usage = 
"HomoginizeData[data, mask] tries to homoginize the data within the mask by removing intensity gradients."

NormalizeData::usage = 
"NormalizeData[data] normalizes the data to the mean signal of the data.
NormalizeData[data,{min,max}] normalizes the data between min and max.
"


(* ::Subsection::Closed:: *)
(*Options*)


Smoothing::usage = 
"Smoothing is an options for Mask, Maskbin and SmartMask functions, if set to true (default) it smooths (removes holes and smooth edges) the mask"

DataType::usage = 
"DataType is an option for ReadGof"

Strictness::usage = 
"Strictness is an option for SmartMask (value of 1 to 6) and SmartMask2 (value between 0 and 1). Low values selects more."

Compartment::usage = 
"Compartment is an option for SmartMask2. Can be \"Muscle\" or \"Fat\"."

SmoothMaskFactor::usage = 
"SmoothMaskFactor is an option for SmartMask."

OptimizationRuns::usage = 
"OptimizationRuns is an option for SmartMask"

MaskRange::usage = 
"MaskRange is an option for SmartMask"


(* ::Subsection::Closed:: *)
(*Error Messages*)


Mask::tresh = 
"Given treshhold `1` value is not a vallid input, must be a number for min treshhold only or a vector {min tresh, max tresh}.";

GetMaskData::tresh = 
"The dimensions of the data and the mask must be the same, dataset: `1`, mask: `2`.";

ReadGof::dat = 
"The given DataType is not valid: `1`. Can be \"Arm\" or \"Mara\".";

ReadGof::file= 
"The given file does not exist: `1`.";

GofImport::file= 
"The given file does not exist: `1`.";

ROIMask::war = 
"there are more slices in the roi set than in the given dimensions"


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection:: *)
(*Mask from gof files*)


(* ::Subsubsection::Closed:: *)
(*ReadROI*)


SyntaxInformation[ReadROI] = {"ArgumentsPattern" -> {_, _, _, _.}};

ReadROI[filename_,voxel_,dim_]:=
Module[{data,output,roi,names,off},
	off=("ImagePosition"/. Import["T1\\00001.dcm","MetaInformation"]);
	{names,roi}=GofImport[filename];
	data=Round[Map[(#-off)/voxel&,roi,{3}]];
	output=Map[{Transpose[{#[[All,1]]+1,-(#[[All,2]]-dim[[2]])}],#[[1,3]]+1}&,data,{2}];
	Return[MapThread[{#1->#2}&,{names,output}]]
]

ReadROI[filename_,voxel_,dim_,off_]:=
Module[{data,output,roi,names},
	{names,roi}=GofImport[filename];
	data=Round[Map[(#-off)/voxel&,roi,{3}]];
	output=Map[{Transpose[{#[[All,1]]+1,-(#[[All,2]]-dim[[2]])}],#[[1,3]]+1}&,data,{2}];
	Return[MapThread[{#1->#2}&,{names,output}]]
	]


(* ::Subsubsection::Closed:: *)
(*ReadGof*)


Options[ReadGof]={DataType->"Normal"};

SyntaxInformation[ReadGof] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

ReadGof[file:{_?StringQ..}, T1:{_?StringQ..},OptionsPattern[]]:= MapThread[ReadGof[#1,#2,DataType->OptionValue[DataType]] &, {file,T1}]

ReadGof[file:{_?StringQ..}, T1_?StringQ,OptionsPattern[] ]:= Map[ReadGof[#,T1,DataType->OptionValue[DataType]] &, file]

ReadGof[file_?StringQ, T1_?StringQ,OptionsPattern[]]:= Module[{slice, pixel, output, off, roifile, T1file, names, roi, data, meta, vox, dim},
	roifile=If[StringTake[file,-4]==".gof",file,file<>".gof"];
	(*T1file=If[StringTake[T1,-4]==".dcm",T1,T1<>".dcm"];*)
	T1file=T1;
	If[FileExistsQ[T1file],
		If[FileExistsQ[roifile],
			{names, roi} = GofImport[roifile], 
			Message[ReadGof::file, roifile]
		];
		meta = Import[T1file,"MetaInformation"];
		slice = "SlicesSpacing" /. meta;
		
		pixel = "PixelSpacing" /. meta;
		If[StringQ[pixel], pixel = "PixelSpacing" /.("(0028,9110)" /.First["(5200,9230)" /. meta])];
		If[OptionValue[DataType] == "Maastricht", pixel = {1, 1}];
		
		vox = Flatten[{slice,pixel}/.meta];
		
		off = "ImagePosition" /. meta;
		off = If[StringQ[off], "ImagePosition" /.First["(0020,9113)" /. First["(5200,9230)" /. meta]],off];
		
		dim = Dimensions[Import[T1file,"Data"]];
		,Message[ReadGof::file, T1file]
	];
	
	Switch[
		OptionValue[DataType]
		,
		"Normal"
		,
		data = Round[Map[(# - off)/{vox[[2]], vox[[3]], vox[[1]]} &, roi, {3}]];
		output = Map[{Transpose[{#[[All, 1]] + 1, -(#[[All, 2]] - dim[[3]])}/{dim[[3]],dim[[2]]}], #[[1, 3]] + 1} & , data, {2}];
		,
		"Maastricht",
		data = Round[Map[#/{vox[[2]], vox[[3]], vox[[1]]} &, roi, {3}]];
		output = Map[{Transpose[{#[[All, 1]] + 1, -(#[[All, 2]] - dim[[3]])}/{dim[[3]], dim[[2]]}], #[[1, 3]] + 1} &, data, {2}];
		,
		"Arm"
		,
		(*off = off - {0, 0, dim[[2]]*vox[[2]]};*)
		data = Round[Map[(# - {off[[1]],off[[3]],off[[2]]})/vox &, roi, {3}]];
		output = Map[{Transpose[{#[[All, 2]] + 1, #[[All, 3]] + 1}/{dim[[3]], dim[[2]]}], -(#[[1, 1]] - dim[[1]])} &, data, {2}];
	];
		
	Return[Thread[names -> output//N]];
];


(* ::Subsubsection::Closed:: *)
(*GofImport*)


SyntaxInformation[GofImport] = {"ArgumentsPattern" -> {_}};

GofImport[file_]:=
Module[{roiData, roiPos, roiSeg, roiNames, roi},
  If[! FileExistsQ[file],
   Message[GofImport::file, file],
   roiData = Import[file, "Lines"];
   roiPos = # - {0, 1} & /@ 
     Partition[
      Append[Flatten[
        Drop[#, -1] & /@ 
         Position[StringPosition[roiData, "ConcaveHull"], {_, _}]], 
       Length[roiData] + 1], 2, 1];
   roiSeg = Take[roiData, #] & /@ roiPos;
   roiNames = 
    StringReplace[
     StringTake[#[[1]], 
        DeleteDuplicates[Flatten[StringPosition[#[[1]], "\""]]]] & /@ 
      roiSeg, "\"" -> ""];
   roi = 1000*
     ToExpression[
      Fold[StringReplace, #, {{") }" -> ")}", "{ (" -> "{{", 
           " " .. -> " ","E"-> "*10^"}, {"( " -> "{", " )" -> "}", "(" -> "{", 
           ")" -> "}"}, {" " -> ","}}] & /@ (Map[
         "{" <> StringTake[#, {StringPosition[#, "("][[1, 1]], 
             StringPosition[#, "}"][[1, 1]]}] &, (StringReplace[#, 
             "}}" -> "}"] & /@ (Drop[#, 1] & /@ roiSeg)), {2}])];
   {roiNames, roi}
   ]
  ]


(* ::Subsubsection::Closed:: *)
(*ROIMask*)


SyntaxInformation[ROIMask] = {"ArgumentsPattern" -> {_, _, _.}};

ROIMask[ROIdim_,maskdim_,ROI:{(_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..})..}]:=
Module[{output},
	output=Map[#[[1]]->ROIMask[ROIdim,maskdim,#[[2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[ROIdim_,maskdim_,ROI:{{_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}}..}]:=
Module[{output},
	output=Map[#[[1,1]]->ROIMask[ROIdim,maskdim,#[[1,2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[ROIdim_,maskdim_,ROI:{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}]:=
Module[{output,ROIcor,ROIslice,msk},
	output=ConstantArray[0,Join[{ROIdim[[1]]},maskdim]];
	If[ROI[[All,1]]!={{{0,0}}},
		ROIcor=Round[ROI[[All,1]]];
		ROIslice=Clip[ROI[[All,2]],{1,ROIdim[[1]]}];
		msk=1-ImageData[Image[Graphics[Polygon[#],PlotRange->{{0,ROIdim[[3]]},{0,ROIdim[[2]]}}],"Bit",ColorSpace->"Grayscale",ImageSize->maskdim]]&/@ROIcor;
		MapIndexed[output[[#1]]=msk[[First[#2]]];&,ROIslice];
		];
	Return[output];
	]

ROIMask[maskdim_,ROI:{(_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..})..}]:=
Module[{output},
	output=Map[#[[1]]->ROIMask[maskdim,#[[2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[maskdim_,ROI:{{_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}}..}]:=
Module[{output},
	output=Map[#[[1,1]]->ROIMask[maskdim,#[[1,2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[maskdim_,ROI:{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}]:=
Module[{output, ROIcor, ROIslice, msk},
 output = ConstantArray[0, maskdim];
 If[ROI[[All, 1]] != {{{0, 0}}},
  ROIcor = Round[Map[Reverse[maskdim[[2 ;; 3]]]*# &, ROI[[All, 1]], {2}]];
  If[Max[ROI[[All, 2]]] > maskdim[[1]], Message[ROIMask::war]];
  ROIslice = Clip[ROI[[All, 2]], {1, maskdim[[1]]}];
  msk = 1 - 
      ImageData[
       Image[Graphics[Polygon[#], 
         PlotRange -> {{0, maskdim[[3]]}, {0, maskdim[[2]]}}], "Bit", 
        ColorSpace -> "Grayscale", 
        ImageSize -> maskdim[[2 ;; 3]]]] & /@ ROIcor;
  MapIndexed[output[[#1]] = msk[[First[#2]]]; &, ROIslice];
  ];
 Return[output];]
 
 


(* ::Subsection::Closed:: *)
(*Mask treshholds*)


Options[Mask]={Smoothing->False};

SyntaxInformation[Mask] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

Mask[data_?ArrayQ,tr_,OptionsPattern[]]:=
Module[{mask,tresh=If[NumberQ[tr],{tr},tr]},
	If[Length[tresh]>2,Message[Mask::tresh,tresh],
		mask=If[Length[tresh]==1,
			UnitStep[data-tresh[[1]]],
			UnitStep[data-tresh[[1]]]-UnitStep[data-tresh[[2]]]
			];
		
		If[OptionValue[Smoothing],
			(*Map[Floor[MedianFilter[#,2]]&,mask,{ArrayDepth[data]-2}]*)
			SmoothMask[mask],
			mask
			]
		]
	]


(* ::Subsection::Closed:: *)
(*Mask binarize*)


Options[MaskBin]={Smoothing->True};

SyntaxInformation[MaskBin] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

MaskBin[data_?ArrayQ,OptionsPattern[]]:=
Module[{mask},
	Map[(
		mask=ImageData[Dilation[Erosion[Binarize[(Image[#,"Byte"])],1],1],"Bit"];
		If[OptionValue[Smoothing],
			(*Floor[MedianFilter[mask,2]]*)
			SmoothMask[mask],
			mask]
		)&,((data/Max[data])*256),{ArrayDepth[data]-2}]
	]


(* ::Subsection::Closed:: *)
(*GetMaskData*)


SyntaxInformation[GetMaskData] = {"ArgumentsPattern" -> {_, _}};

GetMaskData[data_?ArrayQ,mask_?ArrayQ]:=
Module[{depth},
	If[Dimensions[data]!=Dimensions[mask],
		Message[GetMaskData::dim,Dimensions[data],Dimensions[mask]],
		depth=ArrayDepth[data];
		Map[Flatten[#]&,DeleteCases[N[data*mask],0.,{depth}],{depth-2}]
		]
	]


(* ::Subsection:: *)
(*Smart masking*)


(* ::Subsubsection::Closed:: *)
(*SmartMask2*)


Options[SmartMask2]={Strictness->.75,Compartment->"Muscle",Method->"Continuous",Reject->True};

SyntaxInformation[SmartMask2] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

SmartMask2[input_,ops:OptionsPattern[]]:=SmartMask2[input,0,ops]

SmartMask2[input_,m_,OptionsPattern[]]:=
Module[{sol,func,range,map,mask,pmask,Omega,Xi,Alpha,pars},
	pars=If[Length[input]==6,
		PrintTemporary["Caculating Parameters"];
		ParameterCalc[input,Reject->OptionValue[Reject]],
		input];
	
	sol=If[m===0,
		Switch[
			OptionValue[Compartment],
			"Muscle",
			ParameterFit2[pars][[All,{3,5,7}]],
			"Fat",
			ParameterFit2[pars][[All,{2,4,6}]]
			],
		ParameterFit[Flatten[m*#]&/@pars,FitOutput->"BestFitParameters"]
		];
	
	pmask=Mask[pars[[1]],{0.00001}];
	mask=pmask * Switch[OptionValue[Method],
		"Catagorical",
		range=(func=SkewNormalDistribution[#[[2]],#[[1]],#[[3]]];{Quantile[func,.02],Quantile[func,.98]})&/@sol;
		Mask[TotalVariationFilter[Total[MapThread[Mask[#1,#2]&,{pars,range}]]/5,.15],{OptionValue[Strictness]}]
		,
		"Continuous",
		map = MapThread[({Omega, Xi, Alpha} = #2;Map[SkewNormC[#, Omega, Xi, Alpha] &, #1, {ArrayDepth[#1]}]) &, {pars, sol}];
		map = Total[{1, 1, 1, 1, 2}*(#/Max[#] & /@ map)]/6;
		Mask[TotalVariationFilter[map, .35], {OptionValue[Strictness]}]
		(*map=Total[MapThread[({Omega,Xi,Alpha}=#2;Map[SkewNormC[#,Omega,Xi,Alpha]&,#1,{ArrayDepth[#1]}])&,{pars,sol}]];
		Mask[TotalVariationFilter[map/Max[map],.15],{OptionValue[Strictness]}]*)
		]
	]


(* ::Subsubsection::Closed:: *)
(*Smartmask*)


Options[SmartMask]={Smoothing->False,SmoothMaskFactor->.2,OptimizationRuns->1,MaskRange->.8,Strictness->5,Reject->True}

SyntaxInformation[SmartMask] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

SmartMask[input_,mask_,OptionsPattern[]]:=
Module[{data,smooth,sol,spread,smask=mask,tmask,x,Alpha,range,w,sel,strict,runs,smf,Mu,Sigma},
	Off[NonlinearModelFit::"cvmit"];Off[NonlinearModelFit::"sszero"];
	
	(*get option values*)
	range=0.5*Clip[OptionValue[MaskRange],{0.05,0.95}];
	{w,sel,strict}=Stricti[Clip[OptionValue[Strictness],{0,6}]];
	smf=OptionValue[SmoothMaskFactor];
	runs=OptionValue[OptimizationRuns];
	smooth=OptionValue[Smoothing];
	
	(*see if data is tensor, if so calculate diffusion parameters, if not asume its diffusion parameters*)
	data=If[Length[input]==6,PrintTemporary["Caculating Parameters"];ParameterCalc[input,Reject->OptionValue[Reject]],data=input];
	
	PrintTemporary["Making mask"];
	
	(*Loop Throug optimization runs*)
	Do[
		(*Get the solution of the parameter fit for each of the parameters*)
		sol=(NonlinearModelFit[FitData[Flatten[GetMaskData[#,smask]]],PDF[SkewNormalDistribution[Mu,Sigma,Alpha],x],{Mu,Sigma,Alpha},x]["BestFitParameters"])&/@data;
		(*calculate the range of the data selection*)
		spread={Quantile[SkewNormalDistribution[Mu,Sigma,Alpha],0.5-range],Quantile[SkewNormalDistribution[Mu,Sigma,Alpha],0.5+range]}/.sol;
		(*calculate cluster map*)
		tmask=Total[MapThread[Mask[#1,#2,Smoothing->False]&,{data,spread}][[sel]]];
		
		(*chose masking method*)
		smask=Switch[smooth,
			"Raw",(*returns raw cluster map*)
			Return[tmask],
			True,(*returns smoothed mask*)
			Round[TotalVariationFilter[tmask,smf]/w],
			False,(*Returns unsmoothed mask*)
			Round[tmask/w]
			];
		
		(*is strickt is 6 confine mask to input mask*)
		smask=If[strict==6,mask*smask,smask];
		
		(*end loop*)
		,{runs}
		];
	
	On[NonlinearModelFit::"cvmit"];On[NonlinearModelFit::"sszero"];
	Return[smask]
	];


(* ::Subsubsection::Closed:: *)
(*Stricti*)


(* stricktness can be number between 1 and 6 or a vector containing numbers between 1 and 6*)
Stricti[x_?NumberQ]:={x,Range[5],x}
Stricti[x:{_?NumberQ...}]:={Length[DeleteCases[x,6]],DeleteCases[x,6],Max[x]}
Stricti[x:{_?NumberQ,_?ListQ}]:={Clip[x[[1]],{1,Length[DeleteCases[x[[2]],6]]}],DeleteCases[x[[2]],6],Max[x]}


(* ::Subsubsection::Closed:: *)
(*Probability functions*)


Phi[x_]:=1/(E^(x^2/2)*Sqrt[2*Pi]);
CapitalPhi[x_]:=.5(1+Erf[(x)/Sqrt[2]]);
SkewNorm[x_,Omega_,Xi_,Alpha_]:=(2/Omega)Phi[(x-Xi)/Omega]CapitalPhi[Alpha (x-Xi)/Omega];
Delta[a_]:=a/Sqrt[1+a^2];
Mn[w_,e_,a_]:=e+w Delta[a] Sqrt[2/Pi];
Var[w_,a_]:=w^2(1-(2Delta[a]^2/Pi));
SkewNormC=Compile[{{x, _Real},{Omega, _Real},{Xi, _Real},{Alpha, _Real}},
Chop[(2/Omega)(1/(E^(((x-Xi)/Omega)^2/2)*Sqrt[2*Pi]))(.5(1+Erf[((Alpha (x-Xi)/Omega))/Sqrt[2]]))]
];


(* ::Subsection::Closed:: *)
(*MaskDTIdata functions*)


SyntaxInformation[MaskDTIdata] = {"ArgumentsPattern" -> {_, _}};

MaskDTIdata[data_, mask_] := Transpose[mask # & /@ Transpose[data]]


(* ::Subsection::Closed:: *)
(*MaskTensdata functions*)


SyntaxInformation[MaskTensdata] = {"ArgumentsPattern" -> {_, _}};

MaskTensdata[tens_, mask_] := mask # & /@ tens


(* ::Subsection::Closed:: *)
(*SmoothMask functions*)


SyntaxInformation[SmoothMask] = {"ArgumentsPattern" -> {_, _.}};

SmoothMask[mask_, f_: 2] := Block[{n, n1},
  n = 40; n1 = n + 1;
  Round[GaussianFilter[
    Closing[
      ImageData@
       SelectComponents[Image3D[ArrayPad[mask, n]], 
        "Count", -1], n/2
      ][[n1 ;; -n1, n1 ;; -n1, n1 ;; -n1]], f]]
  ]


(* ::Subsection::Closed:: *)
(*NormalizeData functions*)


SyntaxInformation[NormalizeData] = {"ArgumentsPattern" -> {_}};

NormalizeData[data_] := NormalizeDatai[data]
 
NormalizeDatai=Compile[{{data, _Real, 2}}, 
   data/Mean[
     DeleteCases[Flatten[Clip[data, {20, 10000}, {0, 10000}]], 0.]], 
   RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];

NormalizeData[data_,minmax_] := NormalizeDatai[data,minmax]

ScaleData = 
  Compile[{{data, _Real, 0}, {range, _Real, 1}}, 
   (data - range[[1]])/(range[[2]] - range[[1]]), 
   RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];
(* ::Subsection::Closed:: *)
(*NormalizeData functions*)


SyntaxInformation[HomoginizeData] = {"ArgumentsPattern" -> {_, _}};

HomoginizeData[datai_, mask_] := 
 Module[{data, mn, fit, datac, maskout},
  data = mask GaussianFilter[datai, 5];
  mn = Mean[DeleteCases[Flatten[N[data]],0.]];
  fit = FitGradientMap[Erosion[mask, 3] data];
  
  datac = (datai/(fit + 0.001));
  maskout = Mask[datac, 0.1];
  maskout = Dilation[SmoothMask[maskout, 5], 5];
  maskout Clip[mn datac, {0.8, 1.5} MinMax[data], {0, 0}]
  ]
  
  
FitGradientMap[data_] := Module[{func, x, y, z, coor},
  Clear[x, y, z];
  coor = Flatten[
    MapIndexed[
     ReleaseHold@If[#1 == 0, Hold[Sequence[]], Join[#2, {#1}]] &, 
     data, {3}], 2];
  func = Fit[coor, {1, x, y, z, x y, x z, y z, z^2, x^2, y^2(*, z^3, x^3, y^3, z x x, y x x, z y y , x y y , y z z, x z z*)}, {x, y, z}];
  {x, y, z} = TransData[Array[{#1, #2, #3} &, Dimensions[data]], "r"];
  func
  ]


(* ::Section:: *)
(*End Package*)


End[]

SetAttributes[#,{Protected, ReadProtected}]&/@ Names["DTITools`MaskingTools`*"];

EndPackage[]
