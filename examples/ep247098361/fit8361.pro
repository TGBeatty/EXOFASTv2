pro fit8361, debug=debug, verbose=verbose, maxsteps=maxsteps, nthin=nthin

;; default to a very short run (not well-mixed or publication quality)
if n_elements(maxsteps) eq 0 then maxsteps=600 ;; 50000
if n_elements(nthin) eq 0 then nthin=1 ;; 50
path = filepath('',root_dir=getenv('EXOFAST_PATH'),subdir=['examples','ep247098361'])

exofastv2, nplanets=1, tranpath=path+'ep247098361.Kepler.dat',rvpath=path+'ep247098361.APF.rv',$
           priorfile=path+'ep247098361.priors',debug=debug, verbose=verbose, $
           prefix=path + 'fitresults' + path_sep() + 'ep247098361.MIST.',$
           maxsteps=maxsteps,nthin=nthin,$
           fittran=[1],fitrv=[1],circular=[0],/longcadence

end
