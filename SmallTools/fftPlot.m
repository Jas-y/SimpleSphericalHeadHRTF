function fftPlot(x, fs, legends)


n = size(x,1);
%x = [x, zeros(n, 2^15)]; % zero padding
L = length(x);
Xmag = zeros(n,L);
w = [0:L-1].*fs/L;
figure
for i = 1:n
    Xmag(i,:) = abs(fft(x(i,:))); 
    %smoo = sgolayfilt(Xmag(i,:), 5, 501);
    %plot(w(1:L/2), 20*log10(Xmag(i, 1:L/2)))
    semilogx(w(1:L/2), 20*log10(Xmag(i, 1:L/2)))
    %plot(w(1:L/2), 20*log10(smoo(1:L/2)))
    hold on
end
grid on

xlabel('Freq [Hz]')
ylabel('Power [dB]')
[Peak, PeakIdx] = max(Xmag);
% text(w(PeakIdx), 20*log10(Peak), sprintf('Freq = %6.3d Hz', round(w(PeakIdx))))

if nargin > 2
    legend(legends);
    
end

% if isrow(x)
%     x = x';
% end
% 
% stereo = 0;
% 
% if size(x,2) == 2
%     x1 = x(:,1);
%     x2 = x(:,2);
%     stereo = 1;
% end
% 
% if stereo
%     x1 = [x1; zeros(2^15,1)];
%     Xmag1 = abs(fft(x1));
%     w1 = [0:length(x1)-1].*fs/length(x1);
%     
%     x2 = [x2; zeros(2^15,1)];
%     Xmag2 = abs(fft(x2));
%     w2 = [0:length(x2)-1].*fs/length(x2);
%     
%     figure
%     plot(w1(1:length(w1)/2), 20*log10(Xmag1(1:length(Xmag1)/2))); grid on
%     hold on
%     plot(w2(1:length(w2)/2), 20*log10(Xmag2(1:length(Xmag2)/2))); grid on
% else
%     x = [x; zeros(2^15,1)];
%     Xmag = abs(fft(x));
%     w = [0:length(x)-1].*fs/length(x);
%     figure
%     plot(w(1:length(w)/2), 20*log10(Xmag(1:length(Xmag)/2))); grid on
% end
