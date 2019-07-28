FRM=2048;
M = 64; 
k = log2(M);
numSamplesPerSymbol = 1;

MaxNumErrs=200; MaxNumBits=1e7;
EbNo_vector=0:10;BER_vector=zeros(size(EbNo_vector));

BitError = comm.ErrorRate;
for EbNo = EbNo_vector
    snr = EbNo + 10*log10(k) - 10*log10(numSamplesPerSymbol);
    numErrs = 0; numBits = 0; results=zeros(3,1);
    while ((numErrs < MaxNumErrs) && (numBits < MaxNumBits))
        u = randi([0 1],FRM,1);
        mod_sig = qammod(u,M,'bin');
        rx_sig = awgn(mod_sig,snr,'measured');
        y = qamdemod(rx_sig,M,'bin');
        results = step(BitError, u, y);
        numErrs = results(2);
        numBits = results(3);
    end
ber = results(1); bits= results(3);
reset(BitError);
BER_vector(EbNo+1)=ber;
end
EbNoLin = 10.^(EbNo_vector/10);
theoretical_results = (2/M)*(1-(1/sqrt(M)) )*erfc(sqrt(3*M*EbNoLin/(2*(M-1))));
semilogy(EbNo_vector, BER_vector)
grid;title('BER vs. EbNo - 64-QAM modulation');
xlabel('Eb/No (dB)');ylabel('BER');hold;
semilogy(EbNo_vector,theoretical_results,'dr');hold;
legend('Simulation','Theoretical');