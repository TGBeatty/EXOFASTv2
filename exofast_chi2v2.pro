;+
; NAME:
;   EXOFAST_CHI2
;
; PURPOSE: 
;   Computes the chi2 for a transit and/or RV for a single planet
;
; CALLING SEQUENCE:
;    chi2 = exofast_chi2(pars)
;
; INPUTS:
;
;    PARS - An array of parameters that describes the model. There
;           should be one for each parameter in the structure where
;           fit==true
; 
;      pars.rvzeros   ;; the zero points for each RV data set
;      pars.s         ;; a structure describing the star 
;        s.mass       ;; stellar mass
;        s.logg       ;; logg
;        s.teff       ;; effective temperature
;        s.feh        ;; metalicity
;        s.vsini      ;; velocity
;        s.distance   ;; stellar distance
;        s.rstar      ;; stellar radius (derived)
;        s.age        ;; stellar age (derived)
;        s.luminosity ;; stellar luminosity (derived)
;        s.umag       ;; apparent U magnitude
;        s.bmag       ;; apparent B magnitude
;        s.vmag       ;; apparent V magnitude
;        s.rmag       ;; apparent R magnitude
;        s.imag       ;; apparent I magnitude
;        s.jmag       ;; apparent J magnitude
;        s.hmag       ;; apparent H magnitude
;        s.kmag       ;; apparent K magnitude
;        s.sloanumag  ;; apparent sloan u magnitude
;        s.sloangmag  ;; apparent sloan g magnitude
;        s.sloanrmag  ;; apparent sloan r magnitude
;        s.sloanimag  ;; apparent sloan i magnitude
;        s.sloanzmag  ;; apparent sloan z magnitude
;        s.stromumag  ;; apparent stromgren u magnitude
;        s.strombmag  ;; apparent stromgren b magnitude
;        s.stromvmag  ;; apparent stromgren v magnitude
;        s.stromymag  ;; apparent stromgren y magnitude
;        s.ra         ;; right ascension
;        s.dec        ;; declination
;        s.Omega      ;; orienation in real space (??)
;        s.decpm
;        s.rapm 
;        
;     pars.p  ;; an array of structures for each planet and/or observation
;        p.tc       ;; time of inferior conjunction (primary transit)
;        p.logP     ;; log of the period
;        p.qecosw   ;; e^(1/4)*cosw
;        p.qesinw   ;; e^(1/4)*sinw
;        p.logK     ;; log of the RV semi-amplitude
;        p.cosi     ;; cosine of the inclination
;        p.p        ;; Rp/Rstar
;        p.F0       ;; Baseline flux
;        p.lambda   ;; projected Spin-Orbit alignment
;        p.dilution ;; dilution term for the planet
;        p.thermal  ;; thermal emission from the planet (constant offset)
;        p.reflect  ;; reflected flux from the planet (phase dependent)
;        p.beam     ;; beaming from the planet
;        p.ellip    ;; ellipsoidal variation of star (tidally locked to planet)
;        p.band     ;; the observed band
;        p.u1       ;; linear limb darkening (depends on band)
;        p.u2       ;; quadratic limb darkening (depends on band)
;        p.u3       ;; 1st non-linear limb darkening (depends on band)
;        p.u4       ;; 2nd non-linear limb darkening (depends on band)
;        p.slope    ;; linear trend in the RVs C*(time - t0)
;        p.quad     ;; quadratic trend in the RVs C*(time - t0)^2

;    DATA - A structure that describes the data
;    
;    data.tranptrs ;; an array pointers to each transit data set
;      (*tranptrs).trantime    ;; NDATA array of BJD_TDB
;      (*tranptrs).flux        ;; NDATA array of Normalized flux
;      (*tranptrs).fluxerr     ;; NDATA array of flux errors
;      (*tranptrs).detrendmult ;; NTRENDS x NDATA array of multiplicative trends
;      (*tranptrs).detrendsub  ;; NTRENDS x NDATA array of subtractive trends
;    data.rvptrs  ;; an array of pointers to each RV data set
;    data.options ;; a structure of options on how to fit the data
;      options.fitrvs  ;; an NRV array of which RV data sets to fit  
;      options.fittran ;; an NPLANET array of which transit data sets to fit  
;      options.band    ;; an NPLANET array of the observed bands
;      options.exptime ;; an NPLANET array of exposure times
;      options.ninterp ;; an NPLANET array of number of interpolations
;      options.circular ;; an NPLANET array of which planets should be circular
;      options.yy      ;; use the YY isochrones
;      options.tides   ;; include a rough treatment of tidal circularization
;      options.debug   ;; debug

;    PRIORS - A structure that mirrors PARS but with two-element arrays
;             for each parameter [prior, prior width].
;    LABELS - A structure that mirrors PARS but with 3-element strings
;             arrays for each parameter. Each parameter is a 3-element array:
;             Human-readable label
;             Human-readable explanation
;             textoidl form for machine-readable plotting
;             labels.gamma[0] = 'gamma'
;             labels.gamma[1] = 'Systemic velocity (m/s)'
;             labels.gamma[2] = textoidl('\gamma')

;    PARS - a parameter array containing all of the parameters in the
;           model.
;
;           gamma     = pars[0]       ;; systemic velocity
;           slope     = pars[1]       ;; slope in RVs
;           tc        = pars[2]       ;; transit center time
;           logP      = pars[3]       ;; alog10(Period/days)
;           qecosw    = pars[4]       ;; eccentricity/arg of periastron
;           qesinw    = pars[5]       ;; eccentricity/arg of periastron
;           logK      = pars[6]       ;; alog10(velocity semi-amplitude/(m/s))
;           cosi      = pars[7]       ;; cosine of inclination of the orbit
;           p         = pars[8]       ;; rp/rstar
;           log(ar)   = pars[9]       ;; alog10(a/rstar)
;           logg      = pars[10]      ;; stellar surface gravity
;           teff      = pars[11]      ;; stellar effective temperature
;           feh       = pars[12]      ;; stellar metallicity
;           depth2    = pars[13]      ;; secondary eclipse depth
;           u1        = pars[14]      ;; linear limb darkening coeff
;           u2        = pars[15]      ;; quadratic limb darkening coeff
;           u3        = pars[16]      ;; 1st non-linear limb darkening coeff (not supported)
;           u4        = pars[17]      ;; 2nd non-linear limb darkening coeff (not supported)
;           F0        = pars[18]      ;; baseline flux
;           coeffs = pars[19:npars-1] ;; detrending variables
;
; OPTIONAL INPUTS:
;    PSNAME      - The name of a PS file. If set, a plot the
;                  data/model will be written to this file.
; OPTIONAL OUTPUTS:
;    DETERMINANT - The determinant of the parameterization above and
;                  the uniform priors we wish to impose. In this case,
;                  it is always 1d0 (but is required by EXOFAST_DEMC).
;    MODELRV     - The RV model at each time (rv.bjd).
;    MODELFLUX   - The model light curve at each time (transit.bjd).
;   
;
; RESULT:
;    The chi^2 of the model given the data and parameters.
;
; COMMON BLOCKS:
;   CHI2_BLOCK - See exofast.pro for definition
;
; MODIFICATION HISTORY
; 
;  2012/06 -- Public release -- Jason Eastman (LCOGT)
;  2012/07 -- Fixed major bug in mstar/rstar prior width derivation
;  2012/12 -- Add Long cadence, quadratic limb darkening fit.
;  2012/12 -- Changed eccentricity constraint to e < (1-Rstar/a)
;  2013/02 -- Fixed bug that broke detrending, introduced in 2012/12
;  2013/03 -- Changed eccentricity prior:
;               e > (1-Rstar/a-rp/a) -- models are rejected
;               e > (1-3*Rstar/a) -- eccentricity set to zero if options.tides=1
;               now step in e^(1/4)*cos(omega), e^(1/4)*sin(omega) to
;               more closely match the observed prior distribution.
;             Added support for Mstar/Rstar priors, replaces Torres relation
;             Added support for YY evolutionary models, replaces
;             Torres relation
;             Added DERIVED parameter, which returns the age.
;-

function exofast_chi2v2, pars, determinant=determinant, $
                         modelrv=modelrv, modelflux=modelflux, psname=psname, $
                         derived=derived
  
COMMON chi2_block, ss

;; populate the structure with the new parameters
if n_elements(pars) ne 0 then pars2str, pars, ss
AU = 215.094177d0

;; derive all required parameters 
;; (this may change depending on parameterization)
;derivepars, ss

;; initialize the determinant and chi^2
chi2 = 0.d0
determinant = 1d0

;; physical limb darkening
if (where(ss.planet.fittran))[0] ne -1 then begin
   bad = where(ss.band.u1.value + ss.band.u2.value gt 1d0 or $
               ss.band.u1.value + ss.band.u2.value lt 0d0 or $
               ss.band.u2.value lt -1 or ss.band.u2.value gt 1d0, nbad)
   
   if nbad gt 0 then begin
      if ss.debug then print, strtrim(nbad,2) + ' limb darkening parameters are bad'
      return, !values.d_infinity
   endif
endif

;; prevent runaways
bad = where(ss.planet.logp.value gt 7d0 or ss.planet.logp.value lt -1d0,nbad)
;bad = where(ss.planet.logp.value gt 3d0 or ss.planet.logp.value lt 0d0,nbad)
if nbad gt 0 then begin
   if ss.debug then print, 'logP is bad (' + strtrim(bad,2) + ')'
   return, !values.d_infinity
endif

;; prevent runaways
bad = where(ss.planet.tc.value lt ss.planet.tc.prior - 10^ss.planet.logp.value or $
            ss.planet.tc.value gt ss.planet.tc.prior + 10^ss.planet.logp.value,nbad)
if nbad gt 0 then begin
   if ss.debug then print, 'tc is bad (' + strtrim(bad,2) + ')'
   return, !values.d_infinity
endif

;; 0 <= cosi <= 1 (or -1 <= cosi <= 1 if i180 keyword set)
bad = where(ss.planet.cosi.value gt 1 or (ss.planet.cosi.value lt 0 and ~ss.planet.i180) or (ss.planet.cosi.value lt -1),nbad)
if nbad gt 0 then begin
   if ss.debug then print, 'cosi is bad (' + strtrim(bad,2) + ')'
   return, !values.d_infinity
endif

;; older than the universe (too conservative?)
if ss.star.age.value gt 13.82d0 or ss.star.age.value lt 0d0 then begin
   if ss.debug then print, strtrim(nbad,2) + ' age is bad (' + strtrim(bad,2) + ')'
   return, !values.d_infinity
endif

;; positive extinction
if ss.star.av.value lt 0 then begin
   if ss.debug then print, 'extinction is bad (' + strtrim(ss.star.av.value,2) + ')'
   return, !values.d_infinity
endif

;; bound marginally detected planets to limit (infinite) parameter space at low logK
;; conservative lower limit of 0.1 Ceres in 1 year orbit around sun = 1 um/s
;; conservative upper limit corresponds to ~thousand solar masses
bad = where((ss.planet.logk.value lt -6d0 or ss.planet.logk.value gt 6d0) and ss.planet.logk.fit, nbad)
if nbad gt 0 then begin
   if ss.debug then print, 'k is bad (' + strtrim(bad,2) + ')'
   return, !values.d_infinity
endif

;; derive the model parameters from the stepping parameters (return if unphysical)
ss.star.mstar.value = 10^ss.star.logmstar.value
;; use the YY tracks to guide the stellar parameters
if keyword_set(psname) then begin
   chi2 += massradius_yy3(ss.star.mstar.value, ss.star.feh.value, ss.star.age.value, ss.star.teff.value,yyrstar=rstar, debug=ss.debug, psname=psname+'.yy.ps')
endif else begin
   chi2 += massradius_yy3(ss.star.mstar.value, ss.star.feh.value, ss.star.age.value, ss.star.teff.value,yyrstar=rstar, debug=ss.debug)
endelse

if ss.star.errscale.value le 0 then chi2 = !values.d_infinity

if ~finite(chi2) then begin
   if ss.debug then print, 'star is bad'
   return, !values.d_infinity
endif

derived = rstar
ss.star.rstar.value = rstar
if step2pars(ss,verbose=ss.debug) eq -1 then begin
   if ss.debug then print, 'stellar system is bad'
   return, !values.d_infinity
endif

;; add prior penalties
priors = *(ss.priors)
for i=0, n_elements(priors[0,*])-1 do begin

   ;; apply user-defined bounds
   if ss.(priors[0,i])[priors[1,i]].(priors[2,i]).value gt ss.(priors[0,i])[priors[1,i]].(priors[2,i]).upperbound or $
      ss.(priors[0,i])[priors[1,i]].(priors[2,i]).value lt ss.(priors[0,i])[priors[1,i]].(priors[2,i]).lowerbound then $
         return, !values.d_infinity

   chi2 += ((ss.(priors[0,i])[priors[1,i]].(priors[2,i]).value - $
             ss.(priors[0,i])[priors[1,i]].(priors[2,i]).prior)/$
            ss.(priors[0,i])[priors[1,i]].(priors[2,i]).priorwidth)^2

endfor

if 0 then begin
;; prepare the plotting device
if ss.debug or keyword_set(psname) then begin
   if keyword_set(psname) then begin
      ;; astrobetter.com tip on making pretty IDL plots
      mydevice=!d.name
      set_plot, 'PS'
      aspect_ratio=1.5
      xsize=10.5
      ysize=xsize/aspect_ratio
      !p.font=0
      device, filename=psname, /color, bits=24
      device, xsize=xsize,ysize=ysize
      loadct, 39, /silent
      red = 254
      symsize = 0.33
      position1 = [0.23, 0.40, 0.95, 0.95]    ;; data plot
      position2 = [0.23, 0.20, 0.95, 0.40]    ;; residual plot
   endif else begin
      red = '0000ff'x
      symsize = 1
      device,window_state=win_state
;      if win_state[0] eq 1 then wset, 0 $
;      else window, 0, retain=2
      position1 = [0.07, 0.22, 0.97, 0.95]    ;; data plot
      position2 = [0.07, 0.07, 0.97, 0.22]    ;; residual plot
   endelse
endif
endif

;; derive quantities we'll use later
nplanets = ss.nplanets
ntelescopes = ss.ntel
ntransits = ss.ntran
nbands = ss.band
G = 2942.71377d0 ;; R_sun^3/(m_sun*day^2), Torres 2010

;; when no RV is present, constrain the planet mass with mass/radius relations
;; Weiss & Marcy, 2014 (http://adsabs.harvard.edu/abs/2014ApJ...783L...6W)
;; Lissauer et al, 2011 (http://adsabs.harvard.edu/abs/2011ApJS..197....8L)
;; this will implicitly constrain K without RVs
;for j=0, ss.nplanets-1 do begin
;   if not ss.planet[j].fitrv then begin
;      if ss.planet[j].rpearth.value lt 1.5d0 then begin ;; < 1.5 R_earth
;         mp = (2.43d0+3.39d0*ss.planet[j].rpearth.value)*4d0*!dpi*ss.planet[j].rpearth.value^3/3d0
;         ulogmp = 0.811d0
;         err = 2.7d0
;      endif else if ss.planet[j].rpearth.value lt 4d0 then begin
;         mp = 2.69d0*(ss.planet[j].rpearth.value)^0.93d0
;         ulogmp = 0.2978d0
;         err = 4.3d0
;      endif else begin
;         mp = ss.planet[j].rpearth.value^2.06d0
;         err = 400d0
;         ulogmp = 
;      endelse
;      if mp gt 300d0 then err = 900d0 ;; mass/radius degeneracy after ~1 jupiter mass
; 
;      ;; add a chi2 penalty for deviation from the mass-radius relation
;;      chi2 += ((mp - ss.planet[j].mpearth.value)/err)^2
;
;      ;; convert to log space. In linear space, the constraint is only an upper bound
;      logmp = alog10(mp)
;      ulogmp = err/logmp
;
;      chi2 += ((logmp - alog10(ss.planet[j].mpearth.value))/ulogmp)^2
;
;      stop
;
;   endif
;endfor

;; Apply the Mass-Radius relation 
;; Chen & Kipping, 2017 (http://adsabs.harvard.edu/abs/2017ApJ...834...17C)
;; this introduces a near perfect correlation between K and p, which
;; AMOEBA finds challenging to work with (but is handled naturally by DEMC)
for j=0, ss.nplanets-1 do begin
   if ss.planet[j].chen and ~ss.amoeba then begin
      ;; negative radii are allowed to assess the significance of the
      ;; transit. That breaks these relations, so exclude them here
      if ss.planet[j].rpearth.value le 0d0 then return, !values.d_infinity

      rp = massradius_chen(ss.planet[j].mpearth.value,rperr=rperr)
;      rperr = rp*0.2d0 ;; inflate the uncertainty to account for systematics
      ;; add a chi2 penalty for deviation from the mass-radius relation
      ;; if the radius is well-constrained (by transit depth), it
      ;; becomes an implicit constraint on mass. If the mass is well
      ;; constrained (by RV), it becomes an implicit constraint on
      ;; radius
      chi2 += ((rp - ss.planet[j].rpearth.value)/rperr)^2
   endif
endfor

;; fit the SED
if file_test(ss.star.fluxfile) then begin
   if keyword_set(psname) then begin
      sedchi2 = exofast_sed(ss.star.fluxfile, ss.star.teff.value, ss.star.rstar.value,$
                            ss.star.av.value, ss.star.distance.value, $
                            logg=ss.star.logg.value,met=ss.star.feh.value,verbose=ss.debug, f0=f, fp0=fp, ep0=ep, psname=psname+'.sed.ps')
   endif else begin
      sedchi2 = exofast_sed(ss.star.fluxfile, ss.star.teff.value, ss.star.rstar.value,$
                            ss.star.av.value, ss.star.distance.value, $
                            logg=ss.star.logg.value,met=ss.star.feh.value,verbose=ss.debug, f0=f, fp0=fp, ep0=ep)
   endelse 

   if ~finite(sedchi2) then return, !values.d_infinity
   sedchi2 = exofast_like(f-fp,0d0,ss.star.errscale.value*ep,/chi2)
   if ~finite(sedchi2) then return, !values.d_infinity
   chi2 += sedchi2
endif

;; RV model (non-interacting planets)
for j=0, ntelescopes-1 do begin

   rv = *(ss.telescope[j].rvptrs)

   if (where(rv.err^2 + ss.telescope[j].jitter.value le 0d0))[0] ne -1 then return, !values.d_infinity

   modelrv = dblarr(n_elements(rv.rv))
   for i=0, nplanets-1 do begin

      if ss.planet[i].fitrv then begin      
         ;; rvbjd = rv.bjd ;; usually sufficient (See Eastman et al., 2013)

         ;; time in target barycentric frame (expensive)
         rvbjd = bjd2target(rv.bjd, inclination=ss.planet[i].i.value, $
                            a=ss.planet[i].a.value, tp=ss.planet[i].tp.value, $
                            period=ss.planet[i].period.value, e=ss.planet[i].e.value,$
                            omega=ss.planet[i].omega.value,/primary)
         
         ;; calculate the RV model
         modelrv += exofast_rv(rvbjd,ss.planet[i].tp.value,ss.planet[i].period.value,$
                               0d0,ss.planet[i].K.value,$
                               ss.planet[i].e.value,ss.planet[i].omega.value,$
                               slope=0, $
                               rossiter=ss.planet[i].rossiter, i=ss.planet[i].i.value,a=ss.planet[i].ar.value,$
                               p=ss.planet[i].p.value,vsini=ss.star.vsini.value,$
                               lambda=ss.planet[i].lambda.value,$
                               u1=0d0,t0=t0,deltarv=deltarv)

      endif
   endfor
   ;; add instrumental offset, slope, and quadratic term
   modelrv += ss.telescope[j].gamma.value + ss.star.slope.value*(rv.bjd-t0) + ss.star.quad.value*(rv.bjd-t0)^2

   (*ss.telescope[j].rvptrs).residuals = rv.rv - modelrv
   rvchi2 = exofast_like((*ss.telescope[j].rvptrs).residuals,ss.telescope[j].jitter.value,rv.err,/chi2)

   if ~finite(rvchi2) then stop
   chi2 += rvchi2
;   chi2 += total(((rv.rv - modelrv)/rv.err)^2)
endfor

;; if at least one RV planet is fit, plot it
if (where(ss.planet.fitrv))[0] ne -1 then begin
   if keyword_set(psname) then begin
      plotrv, ss, psname=psname + '.rv.ps'
   endif else if ss.debug then begin
      plotrv, ss
   endif
endif

;; Transit model
for j=0, ntransits-1 do begin

   transit = *(ss.transit[j].transitptrs)

   if (where(transit.err^2 + ss.transit[j].variance.value le 0d0))[0] ne -1 then return, !values.d_infinity

   ;; quadratic limb darkening
   band = ss.band[ss.transit[j].bandndx]
   ldcoeffs = quadld(ss.star.logg.value, ss.star.teff.value, ss.star.feh.value, band.name)
   u1claret = ldcoeffs[0]
   u2claret = ldcoeffs[1]
   u1err = 0.05d0 
   u2err = 0.05d0
   chi2 += ((band.u1.value-u1claret)/u1err)^2
   chi2 += ((band.u2.value-u2claret)/u2err)^2

   ;; Kepler Long candence data; create several model points and average   
   ninterp = ss.transit[j].ninterp
   npoints = n_elements(transit.bjd)
   if ninterp gt 1 then begin
      transitbjd = transit.bjd#(dblarr(ninterp)+1d0) + $     
                   ((dindgen(ninterp)/(ninterp-1d0)-0.5d0)/$
                    1440d*ss.transit[j].exptime)##(dblarr(npoints)+1d)
      modelflux = dblarr(npoints,ninterp) + 1d0
   endif else begin
      transitbjd = transit.bjd
      modelflux = dblarr(npoints) + 1d0
   endelse

   for i=0, nplanets-1 do begin
      if ss.planet[i].fittran then begin
         
;         print, ss.planet[0].p.value

         modelflux += (exofast_tran(transitbjd, $
                                    ss.planet[i].i.value, $
                                    ss.planet[i].ar.value, $
                                    ss.planet[i].tp.value + ss.transit[j].ttv.value, $
                                    ss.planet[i].period.value, $
                                    ss.planet[i].e.value,$
                                    ss.planet[i].omega.value,$
                                    ss.planet[i].p.value,$
                                    band.u1.value, $
                                    band.u2.value, $
                                    1d0, $
                                    thermal=band.thermal.value, $
                                    reflect=band.reflect.value, $
                                    dilute=band.dilute.value,$
                                    tc=ss.planet[i].tc.value,$
                                    rstar=ss.star.rstar.value/AU) - 1d0)
;         print, ss.planet[0].p.value

      endif
   endfor
   modelflux *=  ss.transit[j].f0.value
   
   ;; now integrate the model points (before detrending)
   if ninterp gt 1 then modelflux = total(modelflux,2)/ninterp
   
   ;; chi^2
   transitchi2 = exofast_like(transit.flux - modelflux,ss.transit[j].variance.value,transit.err,/chi2)
   (*ss.transit[j].transitptrs).residuals = transit.flux - modelflux
   (*ss.transit[j].transitptrs).model = modelflux
   if ~finite(transitchi2) then stop
   chi2 += transitchi2
;   chi2 += total(((transit.flux - modelflux)/transit.err)^2)

;   screen = GET_SCREEN_SIZE()
;   if win_state(5) then wset, 5 $
;   else window, 5, xsize=xsize, ysize=ysize, xpos=screen[0]/3d0, ypos=0
;   transitchi22 = total((transit.flux - modelflux)^2/(ss.transit[j].variance.value+transit.err^2))
;   plot, transitbjd, transit.flux-modelflux, title=strtrim(transitchi2,2) +  ' ' + strtrim(transitchi22,2), yrange=[-0.001,0.001]


endfor

;; plot the transit model and data 
;; if a transit is fit for at least one planet
if ((where(ss.planet.fittran))[0] ne -1) then begin
   if keyword_set(psname) then begin
      plottran, ss, psname=psname + '.transit.ps'
   endif else if ss.debug then begin
      plottran, ss
   endif
endif

;   plot, transitbjd, transit.flux, psym=1,/ynoz
;   oplot, transitbjd, modelflux, color=red

;; print all the parameters and the chi^2
if ss.debug then print, ss.star.rstar.value, pars, chi2, format='(' + strtrim(n_elements(pars)+2,2) + '(f0.8,x))'

;print, ss.planet[0].p.value
;wait, 0.1
;stop

;if keyword_set(psname) then begin
;   device, /close
;   set_plot, mydevice
;endif

;; if this stop is triggered, you've found a bug!!
if ~finite(chi2) then stop


return, chi2

end

