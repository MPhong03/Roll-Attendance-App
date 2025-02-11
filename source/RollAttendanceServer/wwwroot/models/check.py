import onnx

model = onnx.load("facenet.onnx")
for input in model.graph.input:
    print(input.name, [dim.dim_value for dim in input.type.tensor_type.shape.dim])
