# coding=utf-8
'''
-------------------------------------------------
Author: RenWen
Product Name: PyCharm
Date:  17/11/12
-------------------------------------------------
'''
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn import datasets, linear_model
from numpy.ma.core import getdata


def get_data(file_name):
    data = pd.read_csv(file_name, encoding='gbk')
    x_parameter = []
    y_parameter = []
    for date, output in zip(data['month'], data['Audi A6']):
        # print(type(date),type(output))
        x_parameter.append([float(date)])  # 特征向量
        y_parameter.append(float(output))
    # print(x_parameter, y_parameter)
    return x_parameter, y_parameter


# for month_output in data['']
def linear_model_main(x_parameters, y_parameters, predict_value):
    regr = linear_model.LinearRegression()
    regr.fit(x_parameters, y_parameters)
    predict_output = regr.predict(predict_value)
    predictions = {}
    predictions['intercept'] = regr.intercept_
    predictions['coefficient'] = regr.coef_  # 这里是回归系数
    predictions['predicted_value'] = predict_output
    return predictions


def show_linear_line(x_parameters, y_parameters):
    regr = linear_model.LinearRegression()
    regr.fit(x_parameters, y_parameters)
    plt.scatter(x_parameters, y_parameters)
    plt.plot(x_parameters, regr.predict(x_parameters), color='red', linewidth=4)
    plt.xlabel('month')
    plt.ylabel('output')
    plt.show()


if __name__ == '__main__':
    x, y = get_data('~/Desktop/test1.csv')
    show_linear_line(x, y)
    print(linear_model_main(x, y, 20))
