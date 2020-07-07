function output = convolveFFT(signal1, signal2)
% Convolution in the frequency domain

N1 = length(signal1);
N2 = length(signal2);

if N1*N2 < (N1+N2-1)*(3*log2(N1+N2-1)+1)
    output = conv(signal1, signal2);
else
%     display('Running convolution in the freq domain');
    X1 = fft(signal1,N1+N2-1);
    X2 = fft(signal2,N1+N2-1);
    Y = X1.*X2;
    if (isreal(signal1) && isreal(signal2))
        output = real(ifft(Y));
    else
        output = ifft(Y);
    end
end

end

