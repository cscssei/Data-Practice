# -*- coding: utf-8 -*-
"""
Created on Sat Oct  7 22:07:08 2017

@author: elain
"""

users = {"小明": {"中国合伙人": 5.0, "太平轮": 3.0, "荒野猎人": 4.5, "老炮儿": 5.0, "我的少女时代": 3.0, "夏洛特烦恼": 4.5, "火星救援": 5.0},
         "小红":{"小时代4": 4.0, "荒野猎人": 3.0, "我的少女时代": 5.0, "夏洛特烦恼": 5.0, "火星救援": 3.0, "后会无期": 3.0},
         "小阳": {"小时代4": 2.0, "中国合伙人": 5.0, "我的少女时代": 3.0, "老炮儿": 5.0, "夏洛特烦恼": 4.5, "速度与激情7": 5.0},
         "小四": {"小时代4": 5.0, "中国合伙人": 3.0, "我的少女时代": 4.0, "匆匆那年": 4.0, "速度与激情7": 3.5, "火星救援": 3.5, "后会无期": 4.5},
         "六爷": {"小时代4": 2.0, "中国合伙人": 4.0, "荒野猎人": 4.5, "老炮儿": 5.0, "我的少女时代": 2.0},
         "小李":  {"荒野猎人": 5.0, "盗梦空间": 5.0, "我的少女时代": 3.0, "速度与激情7": 5.0, "蚁人": 4.5, "老炮儿": 4.0, "后会无期": 3.5},
         "隔壁老王": {"荒野猎人": 5.0, "中国合伙人": 4.0, "我的少女时代": 1.0, "Phoenix": 5.0, "甄嬛传": 4.0, "The Strokes": 5.0},
         "邻村小芳": {"小时代4": 4.0, "我的少女时代": 4.5, "匆匆那年": 4.5, "甄嬛传": 2.5, "The Strokes": 3.0}
        }

from math import sqrt
from scipy.spatial import distance

# search the nearest neighbor
def computeNearestNeighbor(username, users):
    distances = []
    for user in users:
        if user != username:
            dist = distance.euclidean(users[user], users[username])
            distances.append((dist, user))
    distances.sort()
    return distances

# recommend
def recommend(username, users):
    # find the nearest neighbor
    nearest = computeNearestNeighbor(username, users)[0][1]
    
    recommendations = []
    # find the movie that the neighbor watched, but the user did not
    neighborRatings = user[nearest]
    userRatings = user[username]
    for movie in neighborRatings:
        if not movie in userRatings:
            recommendations.append((movie, neighborRatings[movie]))
    results = sorted(recommendations, key = lambda movieTuple: artistTuple[1], reverse = True)
    for result in results:
        print(result[0], result[1])

#recommend("小李"， users)

# read data and score with decomposition
import numpy

def matrix_factorization(R, P, Q, K, steps = 5000, alpha = 0.0002, beta = 0.02):
    Q = Q.T
    for step in range(steps):
        for i in range(len(R)):
            for j in range(len(R[i])):
                if R[i][j] > 0:
                    eij = R[i][j] - numpy.dot(P[i,:], Q[:,j])
                    for k in range(K):
                        P[i][k] = P[i][k] + alpha * (2 * eij * Q[k][j] - beta * P[i][k])
                        Q[k][j] = Q[k][j] + alpha * (2 * eij * P[i][k] - beta * Q[k][j])
        eR = numpy.dot(P, Q)
        e = 0
        for i in range(len(R)):
            for j in range(len(R[i])):
                if R[i][j] > 0:
                    e = e + pow(R[i][j] - numpy.dot(P[i,:], Q[:,j]), 2)
                    for k in range(K):
                        e = e + (beta/2) * (pow(P[i][k], 2) + pow(Q[k][j], 2))
        if e < 0.001:
            break
    return P, Q.T

R = [
     [5,3,0,1],
     [4,0,3,1],
     [1,1,0,5],
     [1,0,0,4],
     [0,1,5,4],
     ]

R = numpy.array(R)

N = len(R) # number of rows
M = len(R[0]) # number of column
K = 2

P = numpy.random.rand(N, K)
Q = numpy.random.rand(M, K)

nP, nQ = matrix_factorization(R, P, Q, K)
nR = numpy.dot(nP, nQ.T)