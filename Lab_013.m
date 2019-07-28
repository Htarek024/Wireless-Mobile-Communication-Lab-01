clc;
clear all;
FRM = 512;
MaxNumErrs = 200;
MaxNumBits= 1e7;
EbNo_vector = 0:10;
BER_vector = zeros(size(EbNo_vector));
%%Initialization
Modulator = comm.QPSKModulator('BitInput',true);
AWGN = comm.AWGNChannel;
Demodulator = comm.QPSKDemodulator('BitOutput',true);
BitError = comm.ErrorRate;
%%Outer loop computing bit error rate as a function of EbNo
for EbNo = EbNo_vector
    snr = EbNo + 10*log10(2);
    AWGN.EbNo = snr;
    numErrs = 0;
    numBits = 0;
    results = zeros(3,1);
    %%Inner loop modelling transmitter,channel model and receiver for each EbNo
    while ((numErrs < MaxNumErrs) && (numBits < MaxNumBits))
    %Transmitter
    u = randi([0,1],FRM,1); % Generate Random Bits
    mod_sig = step(Modulator,u); % QPSK Modulator
    % Channel
    rx_sig = step(AWGN,mod_sig); % AWGN Channel
    % Receiver
    y = step(Demodulator,rx_sig); % QPSK Demodulator
    results = step(BitError,u,y); % Update BER
    numErrs = results(2);
    numBits = results(3);
    end
    % Compute BER
    ber = results(1);
    bits = results(3);
    %% Clean up & Collect Results
    reset(BitError);
    BER_vector(EbNo + 1) = ber;
end
%% Visualize Results
EbNoLin = 10.^(EbNo_vector/10);
theoretical_results = 0.5*erfc(sqrt(EbNoLin));
semilogy(EbNo_vector,BER_vector);
grid on;
title('BER Versus EbNo - QPSK Modulation')
xlabel('Eb/No (dB)');
ylabel('BER');
hold;
semilogy(EbNo_vector,theoretical_results,'dr');
hold;
legend('Simulation','Theoretical')