require 'hashmake'
require 'spcore/version'

require 'spcore/core/limiters'
require 'spcore/core/constants'

require 'spcore/windows/bartlett_hann_window'
require 'spcore/windows/bartlett_window'
require 'spcore/windows/blackman_harris_window'
require 'spcore/windows/blackman_nuttall_window'
require 'spcore/windows/blackman_window'
require 'spcore/windows/cosine_window'
require 'spcore/windows/flat_top_window'
require 'spcore/windows/gauss_window'
require 'spcore/windows/hamming_window'
require 'spcore/windows/hann_window'
require 'spcore/windows/lanczos_window'
require 'spcore/windows/nuttall_window'
require 'spcore/windows/rectangle_window'
require 'spcore/windows/triangle_window'

require 'spcore/filters/fir'
require 'spcore/filters/sinc_filter'
require 'spcore/filters/dual_sinc_filter'

require 'spcore/transforms/dft'

require 'spcore/util/scale'
require 'spcore/util/signal_generator'

require 'spcore/lib/interpolation'
require 'spcore/lib/circular_buffer'
require 'spcore/lib/delay_line'
require 'spcore/lib/gain'
require 'spcore/lib/oscillator'
require 'spcore/lib/biquad_filter'
require 'spcore/lib/cookbook_allpass_filter'
require 'spcore/lib/cookbook_bandpass_filter'
require 'spcore/lib/cookbook_highpass_filter'
require 'spcore/lib/cookbook_lowpass_filter'
require 'spcore/lib/cookbook_notch_filter'
require 'spcore/lib/envelope_detector'
require 'spcore/lib/saturation'
