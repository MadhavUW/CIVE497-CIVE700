function [net, tr] = nn_train_net(net, x, t)

nData = size(x,2);

entropy = zeros(nData,1);
is_correct = zeros(nData,1);
for jj=1:nData
    net.input.data = x(:,jj);
    net.output.data = t(:,jj);
    [net, entropy(jj), is_correct(jj)] = forward_prop(net);
    net = backward_prop(net);
end
tr.entropy = mean(entropy);
tr.acc = sum(is_correct)/nData;

end

function [net, entropy, is_correct] = forward_prop(net)

net.layer.inData = transpose(net.input.data'*net.layer.weight + net.layer.bias');
net.layer.outData =  nn_activation(net.layer.inData, net.layer.activation, 'forward');

net.output.inData =  transpose(net.layer.outData' * net.output.weight + net.output.bias');
net.output.outData =  nn_activation(net.output.inData, net.output.activation, 'forward');

% evaluation
entropy = nn_loss(net.output.outData, net.output.data, net.output.loss, 'forward');
[~, I] = max(net.output.outData);
is_correct = isequal(I, find(net.output.data));
end

function net = backward_prop(net)
% output layer
net.output.dEdO = nn_loss(net.output.outData, net.output.data, net.output.loss, 'backward');
net.output.dOdI = nn_activation(net.output.inData, net.output.activation, 'backward');
net.output.dIdW = repmat(net.layer.outData,1,net.output.node);
net.output.dEdI = net.output.dEdO.*net.output.dOdI;
net.output.dEdW = bsxfun(@times, net.output.dEdI' , net.output.dIdW);

net.output.weight = bsxfun(@minus, net.output.weight, net.output.dEdW*net.param.learningrate);
net.output.bias = bsxfun(@minus, net.output.bias,  net.output.dEdI*net.param.learningrate);

% hidden layer
net.layer.dEdO = sum(bsxfun(@times,net.output.dEdI', net.output.weight),2);
net.layer.dOdI = nn_activation(net.layer.inData, net.layer.activation, 'backward');
net.layer.dIdW = repmat(net.input.data,1,net.layer.node);
net.layer.dEdI = net.layer.dEdO.*net.layer.dOdI;
net.layer.dEdW = bsxfun(@times, net.layer.dEdI', net.layer.dIdW);

net.layer.weight = bsxfun(@minus, net.layer.weight, net.layer.dEdW*net.param.learningrate);
net.layer.bias = bsxfun(@minus, net.layer.bias,  net.layer.dEdI*net.param.learningrate);
end