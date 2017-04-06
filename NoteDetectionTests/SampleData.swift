//
//  SampleSpectrum.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.04.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

// Sample Audio Frame / Buffer:

let sampleAudioFrame: [Float] = [-0.00287319, -0.00317097, -0.00330077, -0.00312341, -0.00221658, -0.000985355, 1.24977e-05, 0.000954164, 0.00192317, 0.00235614, 0.00214677, 0.00201611, 0.00202175, 0.00175748, 0.00127687, 0.000805464, 0.000760993, 0.00112504, 0.00117821, 0.00088114, 0.000402832, -0.000415699, -0.000823279, -9.48966e-05, 0.000970821, 0.00117671, 0.000708426, 0.000311265, 0.000174457, 0.000324157, 0.000184217, -0.000553431, -0.00110734, -0.00119863, -0.00124095, -0.00143268, -0.00163074, -0.00153979, -0.00153347, -0.00199224, -0.00218529, -0.00157736, -0.00070659, -0.000422106, -0.000633954, -0.000723256, -0.00089722, -0.00108019, -0.000698738, -3.46706e-05, 5.36344e-05, -0.000746203, -0.00147033, -0.00125862, -0.000899022, -0.00106671, -0.00145223, -0.00222815, -0.00289035, -0.00276523, -0.00286264, -0.00294009, -0.00208071, -0.00154963, -0.00205784, -0.00264892, -0.00271804, -0.00231737, -0.00195839, -0.00191253, -0.00170432, -0.00112219, -0.000426727, 0.000225122, 0.000671047, 0.000617441, 0.000249864, 4.75342e-05, 0.000259158, 0.000828443, 0.0011373, 0.00131913, 0.00205447, 0.00242701, 0.0015873, 0.000814241, 0.00117447, 0.00144638, 0.000543521, -3.33976e-05, 0.000852776, 0.0015696, 0.000995884, 0.000279322, 0.000151683, 4.03982e-05, -9.07223e-05, 0.000282873, 0.000928123, 0.00126419, 0.00136186, 0.00129446, 0.000966418, 0.000881742, 0.00115214, 0.000967191, 0.00048098, 0.000780916, 0.00128225, 0.000817726, -8.08581e-05, -0.000468614, -0.000246887, -7.2918e-05, -0.000437023, -0.00103011, -0.00129651, -0.00134054, -0.00171464, -0.00219262, -0.00257825, -0.00297533, -0.00275071, -0.00193936, -0.00110418, -2.40296e-05, 0.000876231, 0.000765034, -5.42592e-05, -0.00064615, -0.000163728, 0.00109658, 0.00147083, 0.000405317, -0.00031161, 0.000555993, 0.00154673, 0.00101498, -0.000208585, -5.01362e-05, 0.00120212, 0.00110513, -0.000592854, -0.00174458, -0.00117396, 6.39139e-05, 0.000315173, -0.000391409, -0.000650197, -0.000383336, -0.000897165, -0.00162049, -0.00100988, -0.000150259, -0.00079622, -0.00176476, -0.00111218, 0.000130516, 3.78785e-06, -0.000886911, -0.00098666, -0.000220173, 0.000616619, 0.000911549, 0.000718608, 0.000506902, 0.000308548, 0.000282016, 0.00063244, 0.000564551, 0.000140297, 0.000346895, 0.000396267, -0.000589948, -0.00154906, -0.00166963, -0.00122972, -0.000808312, -0.0014433, -0.00299228, -0.00367582, -0.0031778, -0.00275792, -0.00246809, -0.00162755, -0.000780757, -0.000853601, -0.00177787, -0.00270695, -0.00260571, -0.0013556, -0.000571583, -0.0014042, -0.00228107, -0.0018661, -0.00142323, -0.0017757, -0.00196397, -0.00130162, -0.000425388, -0.000336819, -0.000945114, -0.00151809, -0.00145548, -0.000312381, 0.000966961, 0.00110125, 0.00105464, 0.00166421, 0.0022179, 0.00239714, 0.0019604, 0.00108039, 0.000722696, 0.00124744, 0.00207565, 0.00267954, 0.00289017, 0.00257627, 0.0024329, 0.00312518, 0.00357085, 0.00273784, 0.00151504, 0.00101672, 0.000940493, 0.000671992, 0.00032575, -6.92818e-05, -0.000510786, -0.000405333, 0.000100297, 0.000189301, -8.45182e-05, -1.06114e-05, 0.000707328, 0.00126227, 0.000936485, 0.000306688, 0.000528429, 0.00154613, 0.00135093, -0.000638926, -0.00211992, -0.0018804, -0.00101315, -0.000671773, -0.00113614, -0.00170311, -0.0013792, -0.000188076, 0.000712191, 0.000472193, -0.000292977, -0.000656814, -0.000589327, -6.715e-05, 0.000882231, 0.00134755, 0.00119496, 0.00148253, 0.00202517, 0.00189037, 0.0016389, 0.00184962, 0.00165864, 0.000818188, 2.50581e-05, -0.000369955, -8.52103e-05, 0.000716206, 0.00121905, 0.000796899, -0.000247122, -0.000729508, -0.000545553, -0.000397241, 2.44025e-05, 0.000530303, 0.000609857, 0.00089205, 0.00178621, 0.00269083, 0.00278435, 0.00248838, 0.00293534, 0.00347037, 0.00303384, 0.00237654, 0.00183417, 0.0010439, 0.000822333, 0.00132364, 0.00156866, 0.00154635, 0.00129832, 0.000434896, -0.000228079, -0.000306301, -0.000556287, -0.000601666, 1.06705e-05, 0.000666762, 0.00073818, 1.33146e-05, -0.00106129, -0.00159606, -0.00153805, -0.00134008, -0.00080616, -0.000244284, -0.000133273, -0.000284772, -0.000560263, -0.000602515, -0.000291049, -0.00011207, 5.17737e-05, 0.000944938, 0.00213154, 0.0022096, 0.000958181, -0.000425007, -0.000640815, 0.00014561, 0.000703016, 0.00063936, 0.000417893, 0.000681588, 0.0015783, 0.00210605, 0.00147938, 0.000517389, 0.000419926, 0.00112035, 0.00133479, 0.000463992, -0.000439594, -0.000648322, -0.000599552, -0.000629705, -0.00066093, -0.000835084, -0.00109531, -0.000774222, -0.000226482, -0.00055809, -0.00108016, -0.000543754, 0.000248366, 0.000353493, 0.000493373, 0.0010037, 0.00116745, 0.000905803, 0.000773166, 0.000787664, 0.000761598, 0.00105064, 0.0013435, 0.000809993, 0.000403087, 0.000517783, -0.000439064, -0.00179722, -0.00176049, -0.00139954, -0.00190518, -0.00223038, -0.00178864, -0.00126785, -0.000986994, -0.000853125, -0.000959457, -0.00106746, -0.000494563, 0.000228516, 2.98471e-05, -0.000335973, -0.000117356, -0.000513241, -0.00181911, -0.00230945, -0.00166777, -0.0011567, -0.00113645, -0.00115096, -0.00064256, -1.96734e-05, -0.00057467, -0.00169114, -0.00129114, -3.41779e-05, -0.000140761, -0.00110566, -0.0014706, -0.00126241, -0.0007941, -0.000569666, -0.000792886, -0.000641418, -0.000293336, -0.000902448, -0.00202027, -0.00228112, -0.00136589, 2.40766e-05, 0.000650213, 0.000152295, -0.000251537, 6.1047e-05, 0.000101005, -0.000686256, -0.00129299, -0.000881135, -4.3593e-05, 0.000408002, 0.000583263, 0.000621065, -1.83658e-05, -0.000785546, -0.000514992, 0.0001175, 0.000463065, 0.000793169, 0.000583089, -0.000207366, -0.000495839, 2.13125e-05, 0.000584333, 0.000729348, 0.000650124, 0.000861798, 0.00153514, 0.00217345, 0.00260991, 0.00279532, 0.00247133, 0.00201482, 0.00144478, 0.00046717, -6.76202e-05, 0.000141619, -0.000114596, -0.000979872, -0.000959128, 4.74347e-05, 0.000340594, -0.000494175, -0.001286, -0.00104995, 0.000119206, 0.000911843, 0.000602656, 0.000221794, 0.000485009, 0.000639673, 0.000437384, 0.000791403, 0.00146557, 0.00132663, 0.00097626, 0.00129746, 0.00164694, 0.00133126, 0.000815723, 0.000859819, 0.000772504, 0.000245016, 0.000428516, 0.00105223, 0.00125774, 0.00138248, 0.00142841, 0.000980939, 0.000595073, 0.00099137, 0.00133834, 0.000884146, 0.000285011, 0.000178807, 0.000832362, 0.00147606, 0.00118249, 0.000707092, 0.000695173, 0.000541885, -5.48116e-05, -0.000213778, 0.000557306, 0.00106561, 0.000459819, -0.000135349, 0.000180487, 0.000336908, -0.000193185, -0.000624026, -0.000869659, -0.000844004, -0.000486546, -0.000504237, -0.00062235, -7.80475e-05, 0.000660007, 0.000767984, 0.000137468, -0.000626645, -0.00114357, -0.00105393, -0.000486401, -0.00100186, -0.0022864, -0.00224257, -0.00103474, -0.000373125, -0.000860732, -0.00151508, -0.00143004, -0.00103667, -0.00128019, -0.00217538, -0.00263693, -0.00218427, -0.00169539, -0.00191534, -0.00214909, -0.00178786, -0.00154154, -0.00144659, -0.000958531, -0.000469744, -0.000124231, 0.000514813, 0.00076683, -5.61754e-05, -0.000785161, -0.000618634, -0.00050504, -0.00118964, -0.00174918, -0.00142308, -0.00128118, -0.00162874, -0.00154361, -0.00146436, -0.0020398, -0.00240078, -0.00195569, -0.00118306, -0.000254995, 0.00050051, 0.000167057, -0.000757449, -0.00112729, -0.00149874, -0.00232472, -0.00265815, -0.00208454, -0.00119206, -0.00059425, -0.000893009, -0.00188225, -0.00233601, -0.00209534, -0.00176406, -0.00108886, -0.000417144, -0.000635329, -0.00104522, -0.000826457, -0.000416463, -0.000204948, -0.000300868, -0.000604139, -0.000551343, 0.000162248, 0.00115463, 0.00161871, 0.000969976, 9.69407e-05, 0.000377579, 0.00116588, 0.000974927, 0.000330203, 0.000389101, 0.000728119, 0.000425638, -0.000341308, -0.00058389, -0.000570361, -0.00075709, -0.000505068, -0.000163361, -6.68666e-05, 0.000440451, 0.00124049, 0.00150514, 0.000995914, 0.00026333, 2.42953e-05, 0.000329422, 0.000418868, 1.90865e-05, -5.9272e-05, 0.00079618, 0.00178677, 0.00201965, 0.00152072, 0.000193713, -0.00128614, -0.00134975, -0.000262085, 0.000227008, -2.58574e-06, -0.000152108, -0.000253796, 7.66331e-05, 0.000874226, 0.00107426, 0.000550875, -5.19094e-05, -0.000379204, -0.000198702, 0.000274124, 0.000395273, -0.000162758, -0.000872325, -0.000669518, 0.000420187, 0.0010985, 0.00115824, 0.00141464, 0.00201926, 0.00251643, 0.00233986, 0.0018796, 0.00176003, 0.00176992, 0.00197365, 0.0021689, 0.00177763, 0.00110851, 0.000901104, 0.0012579, 0.00158944, 0.00133285, 0.000466708, -0.000231534, -0.000312545, -0.000437087, -0.000946895, -0.00148104, -0.00169858, -0.00127619, -0.000497419, -0.00046516, -0.00105999, -0.00113123, -0.000942808, -0.00127809, -0.00164484, -0.00121318, -0.000372684, 8.57966e-05, 0.000385047, 0.000802231, 0.00073178, 4.87782e-05, -0.000196529, 0.000290361, 0.000233418, -0.000614604, -0.000952187, -0.000848486, -0.000934215, -0.000885715, -0.000720824, -0.000465209, -6.24611e-05, 0.000174361, 0.000453531, 0.00128678, 0.00224913, 0.00213147, 0.000802523, -0.000110293, 5.76823e-05, 0.000452588, 0.000837388, 0.000950379, 0.000688353, 0.000557834, 0.000388292, -0.00014986, -0.000431894, 0.00030843, 0.00109218, 0.000719446, 0.000129505, 0.000438369, 0.00091383, 0.000364494, -0.00034324, 0.000109158, 0.000571904, 0.000164716, 0.000324795, 0.00135993, 0.00151193, 0.000591204, 0.00020012, 0.000575049, 0.000722947, 0.000538059, 0.000600832, 0.000616572, 0.000167038, -8.88919e-05, 0.000384489, 0.00137924, 0.00214803, 0.00208543, 0.00168565, 0.00173855, 0.00212348, 0.00226566, 0.00216416, 0.00181112, 0.00119334, 0.000720693, 3.95467e-05, -0.00102344, -0.0014178, -0.000731041, 6.72284e-05, 0.000184122, 3.42671e-05, 5.44748e-06, -0.000243952, -0.000461721, 7.93835e-06, 0.000751891, 0.0013124, 0.00190039, 0.00214461, 0.00171472, 0.0012859, 0.00143632, 0.0014577, 0.000785207, 0.000315418, 0.000462008, 0.000555572, 0.000127291, -0.000814018, -0.00141612, -0.00104218, -0.00052079, -0.000346562, -0.000116258, -0.000110756, -0.000723702, -0.00136002, -0.00119185, -0.000621436, -0.000555299, -0.000420067, 0.000145014, 0.000322071, 0.000349641, 0.000678912, 0.000677311, 0.000261799, 2.83264e-05, 1.14476e-05, 6.66427e-05, 6.66559e-05, -7.10109e-05, -9.02521e-05, -0.000111845, -0.000414256, -0.000579448, -0.000262707, -0.000234653, -0.00101037, -0.00167317, -0.00164206, -0.00126474, -0.000888477, -0.00113811, -0.00200712, -0.00179883, -0.000340916, -3.72288e-05, -0.000945786, -0.00119275, -0.00108866, -0.00139504, -0.00168241, -0.00167279, -0.00128672, -0.000516364, 0.000207942, 0.000752935, 0.00111688, 0.000722839, -9.71421e-05, -0.000143409, 0.000408674, 0.000657089, 0.00062696, 0.00026078, -0.00049882, -0.000558233, 0.000147056, 0.000187227, -0.000655053, -0.00131581, -0.00106925, -0.000677567, -0.00102693, -0.00144543, -0.00144121, -0.00143088, -0.0015183, -0.00153319, -0.00144363, -0.00118676, -0.000873101, -0.00078383, -0.00104454, -0.00146512, -0.00143671, -0.00106741, -0.00109514, -0.00128202, -0.0012287, -0.00127483, -0.00155537, -0.0015187, -0.000874673, -0.000437768, -0.000637328, -0.000726819, -0.000470717, -0.000223745, 0.000147307, 0.000621549, 0.000768326, 0.00052811, 9.83532e-05, -0.000121184, 0.000216432, 0.00068612, 0.000577024, 0.000360479, 0.00123762, 0.0022853, 0.00148405, -0.00053042, -0.00150376, -0.00083544, -8.45245e-05, -0.000414609, -0.000621157, 0.000338468, 0.00109186, 0.000638355, 5.50255e-05, -3.16528e-05, 1.07897e-05, 0.000441622, 0.00109408, 0.000876687, 0.000100453, -4.41604e-05, 0.000184267, -1.12753e-05, -0.00049326, -0.000610404, -0.000297345, -0.000232798, -0.000634628, -0.000765687, 2.17912e-05, 0.001262, 0.00167218, 0.000999263, 0.000695737, 0.00119105, 0.00122021, 0.000680668, 0.000789591, 0.00178221, 0.0024797, 0.00251108, 0.00257002, 0.00260252, 0.00235131, 0.00217566, 0.00217606, 0.00197813, 0.00200318, 0.00230866, 0.00179473, 0.00101296, 0.00130736, 0.00183972, 0.00136126, 0.000696303, 0.000653914, 0.000421436, -0.000114902, -0.000192275, -0.000154058, -0.000511149, -0.000585472, -0.000235044, -0.000229785, -0.000471072, -0.000804419, -0.00155879, -0.00218727, -0.00211465, -0.00186512, -0.00182049, -0.00183461, -0.00183691, -0.00164733, -0.00107197, -6.8917e-05, 0.000628836, 0.000314714, 0.000206584, 0.000862881, 0.000814149, -8.77483e-05, -0.000674411, -0.000702708, -0.000804204, -0.0013237, -0.00161283, -0.00112876, -0.000431405, -0.000194486, -0.000673847, -0.00133533, -0.00133229, -0.0007083, 0.000334977, 0.00106899, 0.000632968, -0.000239888, -0.00056587, -0.000399235, -0.00013137, 0.000208737, 0.000542617, 0.000494968, 0.000335754, 0.000457693, 0.000471175, 0.000120087, -0.000606872, -0.00138671, -0.00116243, -5.67659e-05, 0.000312852, -0.000290896, -0.000579502, -0.000466381, -0.000743767, -0.001267, -0.00173976, -0.00201078, -0.00162048, -0.000946867, -0.001042, -0.00156598, -0.00134241, -0.000467585, 0.000179066, 0.000239097, -4.40287e-05, -0.000382368, -0.000764207, -0.00114929, -0.00134338, -0.00101726, -7.04545e-05, 0.000564762, 0.000186881, -0.000344547, -0.000211781, 0.000459406, 0.00109681, 0.00110242, 0.000498814, -0.000177469, -0.000320721, 0.000214626, 0.000677848, 0.000568245, 0.00017518, -0.000373582, -0.000632906, 9.3991e-05, 0.00124083, 0.00171561, 0.00137796, 0.000676217, 3.39924e-05, -0.000153534, 0.000302048, 0.000889103, 0.00100514, 0.000848863, 0.00062903, 0.000107819, -0.000210509, 0.000202469, 0.000531693, 0.000557838, 0.000705256, 0.000436421, 0.000109707, 0.000813954, 0.00187646, 0.0020361, 0.00124941, 0.000461004, 0.000545167, 0.000961751, 0.000906159, 0.000819853, 0.00084243, 0.000329514, -0.000739297, -0.0016453, -0.00181882, -0.00153753, -0.00117079, -0.000916448, -0.00116609, -0.00132673, -0.0010861, -0.00111814, -0.00096792, -0.000446677, -0.000464851, -0.00088319, -0.00122525, -0.00161946, -0.00165044, -0.00124041, -0.00118034, -0.00179801, -0.00231909, -0.00145723, 0.000148778, 0.000460478, -0.000227188, 0.000121504, 0.00133364, 0.00137221, 0.000142862, -0.000493847, 0.000308573, 0.0014356, 0.00174004, 0.00120615, 0.000529572, 0.000742288, 0.00145135, 0.00110107, -3.0943e-05, -0.000610325, -0.000638435, -0.000443648, -7.12557e-05, 0.000228884, 0.000343037, 0.000337524, 0.000500118, 0.000524996, -6.62742e-05, -0.000401904, 0.000346783, 0.00140408, 0.00154201, 0.000947356, 0.000797098, 0.00128123, 0.00156297, 0.0014981, 0.00147701, 0.0010817, 0.000116167, -0.000576987, -0.000380616, 7.66523e-05, -1.12042e-05, -0.000103458, 0.000230511, 0.000192863, -0.000354228, -0.000352343, 0.000253841, 0.000383432, 0.00020482, 0.000460418, 0.000753449, 0.000767238, 0.00080066, 0.000941616, 0.00113427, 0.00136142, 0.00182926, 0.002256, 0.00157027, 0.000255383, -0.00044172, -0.000991866, -0.00187847, -0.00254445, -0.00255373, -0.00201423, -0.00116676, -0.000424912, -0.000323045, -0.000385956, -3.74956e-05, -0.000137046, -0.000813739, -0.000876913, -0.000604777, -0.00105534, -0.00177102, -0.00165668, -0.000568799, 0.000497955, 0.000368882, -0.000559122, -0.000916999, -0.000609051, -0.000422923, -0.000762334, -0.00103813, -0.000414685, 0.000607725, 0.00122166, 0.0016092, 0.00181947, 0.00138888, 0.000784818, 0.000779798, 0.000837731, 0.000581655, 0.000453779, 0.000404049, -0.000121454, -0.00104558, -0.00119437, -0.000334988, 0.000297562, 0.000284206, 0.000108406, 4.09539e-07, -2.31901e-05, -5.99683e-05, -0.000122324, 0.000122171, 0.000542063, 0.000586365, 0.000465907, 0.000202807, -0.000702297, -0.00142939, -0.000956009, -0.00031588, -0.00083342, -0.0015903, -0.00120321, -0.000429257, -0.000592875, -0.00128574, -0.00123917, -0.00058571, -0.00040897, -0.000350593, 0.000231827, 0.000560613, 0.000422703, 0.00055649, 0.000764057, 0.000503063, 0.000215544, 0.00032763, 0.000429539, 0.000273172, 0.000157626, 7.5152e-05, -0.000332149, -0.00104334, -0.00144711, -0.00123331, -0.00091706, -0.000650734, -0.000222664, 0.000200405, 0.000195232, -0.000291012, -0.000462259, -9.17112e-05, 0.00018982, 0.000158602, -4.46516e-05, -0.000291813, -0.000205591, 0.000490255, 0.00122422, 0.00166436, 0.00206379, 0.00213712, 0.00179815, 0.00173462, 0.00214756, 0.00227604, 0.00179212, 0.00145042, 0.00162283, 0.00174319, 0.00138154, 0.000930019, 0.000924738, 0.00105491, 0.00087638, 0.000190512, -0.000757422, -0.00117298, -0.00108165, -0.000843356, -0.000684637, -0.000665965, -0.000217624, 0.000637435, 0.00142423, 0.00157491, 0.000532294, -0.000611452, -0.000567473, -0.000284725, -0.000489942, -0.000315307, 0.000159193, 0.000109674, -0.000173756, -0.000178834, -0.000452479, -0.000989927, -0.000619908, 0.000389869, 0.000710515, 0.000253284, -0.000239984, -2.22092e-05, 0.000999244, 0.00161036, 0.000768704, -0.000427277, -0.000735165, -0.000664876, -0.000361463, 0.000244777, 0.00018878, -0.000614684, -0.000817243, -0.000157176, 0.000218036, -0.00025732, -0.00127951, -0.00192428, -0.00202069, -0.00210604, -0.00144619, -0.000300163, -0.000574495, -0.00194346, -0.00231898, -0.00156567, -0.0010863, -0.00109651, -0.00104287, -0.00131053, -0.00197515, -0.00211311, -0.00180562, -0.00161521, -0.00115199, -0.00033805, -4.97743e-05, -0.000804024, -0.00182701, -0.00190485, -0.00100505, -0.000340878, -0.00047828, -0.000862063, -0.00133184, -0.00182627, -0.00189217, -0.00163783, -0.00141399, -0.00122802, -0.0010147, -0.000912809, -0.000774106, -0.000168467, 0.000489343, 0.000585325, 0.000528202, 0.000639588, 0.000623019, 0.000701766, 0.000780197, 0.000591002, 0.000840913, 0.00142663, 0.00131337, 0.000436446, -0.000422938, -0.000755538, -0.00068765, -0.000789254, -0.00120814, -0.00111193, -0.000237073, 0.000459132, 0.000708067, 0.000732931, 0.000205728, -0.000234376, 0.000352706, 0.000993646, 0.000637174, 0.000394647, 0.00105061, 0.00140187, 0.000801907, 0.000193176, 0.000318666, 0.000569521, 0.000419638, 0.000132576, -0.000214978, -0.000541113, -0.000617926, -0.000288491, -5.13847e-05, -0.000304584, -0.000162677, 0.000554738, 0.00116725, 0.00162997, 0.00153073, 0.000914705, 0.000864105, 0.00124031, 0.00135341, 0.00141833, 0.00159445, 0.00197432, 0.00276412, 0.00356174, 0.00343929, 0.00234284, 0.00164417, 0.00182754, 0.00192048, 0.00177854, 0.00179006, 0.0017894, 0.00140871, 0.000743948, 0.000770815, 0.00151672, 0.00178254, 0.00139208, 0.000970496, 0.000749886, 0.000465907, 0.000114606, 0.00014197, 0.000552518, 0.00108195, 0.00132615, 0.000785876, -2.15841e-05, -0.000326287, -0.000186305, 0.000262188, 0.000876035, 0.00150394, 0.00171607, 0.00157733, 0.00175412, 0.00140512, 0.000206423, -0.000418113, -0.000127879, 0.000316063, 0.000186282, -0.000749, -0.00174614, -0.00208381, -0.00196866, -0.00182708, -0.00161461, -0.0016271, -0.00229706, -0.00262781, -0.00204005, -0.00168059, -0.00171302, -0.00145301, -0.000949234, -0.00029252, 1.34656e-05, -0.000489742, -0.00106883, -0.00128352, -0.00138509, -0.00136274, -0.0011515, -0.000886116, -0.000856475, -0.00104753, -0.00119988, -0.00121709, -0.00105626, -0.000730558, -0.000305424, 2.19148e-05, 7.10864e-05, 0.000112012, 0.000481323, 0.000831802, 0.000705219, 0.000404195, 4.7528e-05, -0.000762245, -0.00151269, -0.00144263, -0.000790198, -0.000140847, -1.35271e-05, -0.000355115, -0.000422873, -9.62372e-06, 0.000428282, 0.00065735, 0.00056671, 0.000256626, 6.4721e-05, 0.000134502, 0.000316461, 0.000310189, 0.000133695, -8.19153e-06, 0.000154105, 0.000395702, 0.000192671, 0.000153338, 0.000764831, 0.00111378, 0.000901616, 0.000777147, 0.000481499, -1.46201e-05, 0.000116089, 0.000836472, 0.00124862, 0.000769867, 0.000236125, 0.000751351, 0.00159506, 0.00177811, 0.00129795, 0.000417902, 0.000148926, 0.000547356, -0.000127039, -0.00171194, -0.00221057, -0.00148307, -0.000914814, -0.00103442, -0.0013266, -0.00124395, -0.000652102, -0.000118014, -0.000286531, -0.000581562, -0.000675217, -0.00101722, -0.000993045, -0.000402413, -0.000324825, -0.00112202, -0.00197314, -0.0019541, -0.00128652, -0.000981648, -0.00140167, -0.00183855, -0.00156934, -0.00116284, -0.00132587, -0.00153822, -0.0013766, -0.00110175, -0.000760851, -0.000366071, -0.000221003, -0.000435944, -0.000680733, -0.00088574, -0.00114793, -0.00113273, -0.000751303, -0.000278998, -0.000154879, -0.000329706, -0.000133951, 0.000321868, 0.000631659, 0.000833202, 0.00121582, 0.00164482, 0.00122658, 0.000194109, -0.000243034, 1.8716e-05, 9.25945e-05, -0.000247637, -0.000187615, 0.000419486, 0.000604192, 0.000128262, 0.00020612, 0.000927569, 0.000444877, -0.00119816, -0.00163126, -0.000626706, -0.000157664, -0.00050196, -0.000544863, -0.000228327, -0.000304223, -0.000788772, -0.000883073, -0.000683889, -0.000943552, -0.00129942, -0.00126305, -0.00126781, -0.00154318, -0.00164374, -0.00132358, -0.000889204, -0.000566358, -0.000710969, -0.00130053, -0.00126879, -0.000410792, 0.000361224, 0.000555843, 0.000311384, 0.000188153, 0.000252802, 0.000299779, 0.000640639, 0.000982133, 0.00068741, 0.000358718, 0.000786194, 0.00137437, 0.00143142, 0.00107867, 0.000976843, 0.00150485, 0.00159868, 0.000896635, 0.000649785, 0.000850208, 0.000204179, -0.000828158, -0.000581344, 0.000495695, 0.000904619, 0.000431028, -0.00020979, -0.000496374, -0.000475439, -3.63298e-05, 0.000733443, 0.001507, 0.00211773, 0.00211203, 0.0013422, 0.000640465, 0.000790101, 0.00112717, 0.000980505, 0.00103254, 0.00165073, 0.00246014, 0.00286027, 0.00232232, 0.00141614, 0.00128686, 0.00215498, 0.00295402, 0.00266394, 0.00178745, 0.00123418, 0.00124927, 0.0017553, 0.00234904, 0.00245853, 0.00175103, 0.000970278, 0.000961267, 0.0011262, 0.00100112, 0.000856451, 0.000830378, 0.000987938, 0.00101037, 0.000784898, 0.000559977, 0.000239461, 1.29983e-05, 0.000189362, 0.000525331, 0.000565758, 0.000226193, -6.57721e-05, -0.000182606, -0.000297784, -0.000232336, -0.000130887, -0.000136389, 7.08181e-05, 0.000230621, -0.0001135, -0.000885415, -0.00124127, -0.000635487, -3.49333e-05, -3.08427e-05, -0.000211465, -0.000264514, 2.9194e-05, 0.000444379, 0.000352829, -0.000153055, -0.000117801, 0.000289021, -4.36199e-05, -0.000592227, -0.00061787, -0.000749803, -0.00109447, -0.000926079, 5.07273e-06, 0.00073963, 0.000129872, -0.00113618, -0.00121907, -0.000171551, 0.000263574, -7.92847e-05, -0.000295278, -0.000430981, -0.000701442, -0.00107905, -0.00159646, -0.00174724, -0.00119329, -0.000777091, -0.00102227, -0.00123647, -0.000801093, -0.000310896, -0.0006325, -0.0012481, -0.00103406, -0.000446444, -0.000574973, -0.000656587, -5.91099e-05, 0.00012304, -0.000416414, -0.000781554, -0.000705235, -0.000600284, -0.000565113, -0.000592768, -0.00102939, -0.00169165, -0.00165288, -0.00096221, -0.000775873, -0.00121692, -0.00125573, -0.0006794, -0.00041576, -0.000749646, -0.000923776, -0.000706272, -0.000811984, -0.00133434, -0.00155394, -0.00154264, -0.00111872, 7.84779e-05, 0.000672619, -0.000212934, -0.00141418, -0.00175747, -0.00133395, -0.000970357, -0.00112898, -0.00162259, -0.00168417, -0.00111737, -0.000970333, -0.00107031, -0.000266226, 0.000816216, 0.000958238, 0.000593743, 0.000604059, 0.000487647, 9.06424e-05, 0.000304602, 0.00089025, 0.00101931, 0.000725278, 0.000242211, -0.00027548, -0.000454173, -0.00014987, 0.000174561, 0.000300386, 0.0007737, 0.00118058, 0.000735344, 0.000430133, 0.000785408, 0.000871035, 0.000624619, 0.000510974, 0.000464043, 0.000417777, 0.00048281, 0.00075033, 0.000947974, 0.0005901, -3.69209e-06, -9.18044e-05, 0.000197494, 0.000121591, -0.000232881, -0.000128053, -9.29311e-07, -0.000267917, -4.82984e-05, 0.000564569, 0.000582322, 0.000141823, 3.81776e-05, 0.000413748, 0.000726549, 0.000953876, 0.00138472, 0.00157542, 0.00153801, 0.00166372, 0.00146535, 0.00115245, 0.00177718, 0.00239342, 0.00142065, 0.000242661, 0.000404006, 0.00102758, 0.00156132, 0.00210495, 0.00229523, 0.00228805, 0.00236794, 0.00209069, 0.00153475, 0.00117491, 0.000928751, 0.00067985, 0.000458694, 0.00068512, 0.00126004, 0.00114603, 0.00040364, -0.000141782, -0.000402898, -0.000237928, 0.000514135, 0.00111349, 0.000475112, -0.00118413, -0.00205137, -0.00154936, -0.000890114, -0.000633843, -0.000855331, -0.00142027, -0.00142708, -0.000582587, -0.000110291, -0.000681987, -0.00113015, -0.000993046, -0.00102425, -0.00116092, -0.00123045, -0.0012484, -0.000876503, -0.000451203, -0.00044328, -0.000203941, 0.000518586, 0.000674808, 0.000169152, 6.79533e-05, 0.000473416, 0.000546745, -1.01655e-05, -0.000279323, 0.000104204, 4.75456e-05, -0.000401134, -7.69343e-05, 0.000671761, 0.000720856, 0.000187998, 5.16534e-06, 0.000520973, 0.000816105, 0.000137223, -0.000160169, 0.000815573, 0.0014042, 0.000549963, -0.000773144, -0.00151178, -0.00141137, -0.000605063, 0.000118231, -9.12828e-05, -0.000811004, -0.00118798, -0.0010116, -0.000777091, -0.00118111, -0.00185733, -0.00163744, -0.0008514, -0.000831661, -0.00132235, -0.00137248, -0.00102754, -0.000740328, -0.000385748, -0.000169528, -0.00103102, -0.00261376, -0.00336071, -0.00286546, -0.00231419, -0.00224312, -0.0022128, -0.00214305, -0.00176805, -0.00113386, -0.000904345, -0.00100342, -0.000639853, 6.97763e-05, -0.000131754, -0.00128756, -0.00198114, -0.0017727, -0.00138013, -0.0013042, -0.00153213, -0.0016339, -0.00126729, -0.00106777, -0.00170819, -0.00222011, -0.0017787, -0.00144529, -0.00168276, -0.00151153, -0.000594622, 0.000208596, 3.42206e-05, -0.000392098, -6.5569e-05, 0.000181682, -8.49172e-05, 0.00010222, 0.000722015, 0.000989929, 0.000890304, 0.00106302, 0.00155828, 0.00157344, 0.00124144, 0.00113905, 0.00056849, -0.000347693, -0.000191529, 0.000597183, 0.000875767, 0.000959926, 0.00104081, 0.00086197, 0.000622364, 0.000652164, 0.000970368, 0.00117944, 0.000804235, 0.000328771, 0.000324467, 0.000528294, 0.000844265, 0.000816507, 0.000303454, 0.000301835, 0.000894695, 0.00103027, 0.000299203, -0.000616995, -0.000815209, -0.000150389, 0.000399209, 0.000502114, 0.000850161, 0.000953529, 0.000505594, 0.000222441, -2.79263e-05, -0.000292142, -0.000275228, -0.000187152, -1.1428e-05, 0.00010405, 0.000138068, 0.000715882, 0.00165092, 0.00185225, 0.000988182, 0.000105398, 1.79263e-05, 0.000258668, 0.000344896, 0.000575958, 0.000960534, 0.0011315, 0.00116257, 0.000942296, 0.000670747, 0.000694752, 0.000537499, 0.000438204, 0.00095115, 0.00155234, 0.00177243, 0.00150455, 0.000939278, 0.000886813, 0.00153907, 0.00181433, 0.00102908, 0.000179211, 0.00013507, 0.000437967, 0.000518775, 0.000120147, -0.000127214, 0.00051, 0.00116034, 0.000982234, 0.00064039, 0.000986924, 0.00175176, 0.00192068, 0.00122451, 0.000547595, 0.00086731, 0.0018965, 0.00209915, 0.00144567, 0.0013792, 0.00177968, 0.0017781, 0.00114371, 0.00040545, 0.000376135, 0.000643481, 0.000485955, -3.74939e-06, -0.000372707, -0.000153688, 0.000523694, 0.000723463, 0.000113259, -0.000256732, 1.43767e-05, 0.000156344, -5.37051e-05, -0.000366944, -0.000760033, -0.00103354, -0.000960265, -0.000877464, -0.000837562, -0.000677829, -0.000782137, -0.000905418, -0.000525494, 1.66374e-06, 9.37623e-06, -0.000695837, -0.00107945, -0.000365619]
