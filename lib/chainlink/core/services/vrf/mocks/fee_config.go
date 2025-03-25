// Code generated by mockery v2.53.0. DO NOT EDIT.

package mocks

import (
	common "github.com/ethereum/go-ethereum/common"
	assets "github.com/smartcontractkit/chainlink-integrations/evm/assets"

	config "github.com/smartcontractkit/chainlink-integrations/evm/config"

	mock "github.com/stretchr/testify/mock"
)

// FeeConfig is an autogenerated mock type for the FeeConfig type
type FeeConfig struct {
	mock.Mock
}

type FeeConfig_Expecter struct {
	mock *mock.Mock
}

func (_m *FeeConfig) EXPECT() *FeeConfig_Expecter {
	return &FeeConfig_Expecter{mock: &_m.Mock}
}

// LimitDefault provides a mock function with no fields
func (_m *FeeConfig) LimitDefault() uint64 {
	ret := _m.Called()

	if len(ret) == 0 {
		panic("no return value specified for LimitDefault")
	}

	var r0 uint64
	if rf, ok := ret.Get(0).(func() uint64); ok {
		r0 = rf()
	} else {
		r0 = ret.Get(0).(uint64)
	}

	return r0
}

// FeeConfig_LimitDefault_Call is a *mock.Call that shadows Run/Return methods with type explicit version for method 'LimitDefault'
type FeeConfig_LimitDefault_Call struct {
	*mock.Call
}

// LimitDefault is a helper method to define mock.On call
func (_e *FeeConfig_Expecter) LimitDefault() *FeeConfig_LimitDefault_Call {
	return &FeeConfig_LimitDefault_Call{Call: _e.mock.On("LimitDefault")}
}

func (_c *FeeConfig_LimitDefault_Call) Run(run func()) *FeeConfig_LimitDefault_Call {
	_c.Call.Run(func(args mock.Arguments) {
		run()
	})
	return _c
}

func (_c *FeeConfig_LimitDefault_Call) Return(_a0 uint64) *FeeConfig_LimitDefault_Call {
	_c.Call.Return(_a0)
	return _c
}

func (_c *FeeConfig_LimitDefault_Call) RunAndReturn(run func() uint64) *FeeConfig_LimitDefault_Call {
	_c.Call.Return(run)
	return _c
}

// LimitJobType provides a mock function with no fields
func (_m *FeeConfig) LimitJobType() config.LimitJobType {
	ret := _m.Called()

	if len(ret) == 0 {
		panic("no return value specified for LimitJobType")
	}

	var r0 config.LimitJobType
	if rf, ok := ret.Get(0).(func() config.LimitJobType); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(config.LimitJobType)
		}
	}

	return r0
}

// FeeConfig_LimitJobType_Call is a *mock.Call that shadows Run/Return methods with type explicit version for method 'LimitJobType'
type FeeConfig_LimitJobType_Call struct {
	*mock.Call
}

// LimitJobType is a helper method to define mock.On call
func (_e *FeeConfig_Expecter) LimitJobType() *FeeConfig_LimitJobType_Call {
	return &FeeConfig_LimitJobType_Call{Call: _e.mock.On("LimitJobType")}
}

func (_c *FeeConfig_LimitJobType_Call) Run(run func()) *FeeConfig_LimitJobType_Call {
	_c.Call.Run(func(args mock.Arguments) {
		run()
	})
	return _c
}

func (_c *FeeConfig_LimitJobType_Call) Return(_a0 config.LimitJobType) *FeeConfig_LimitJobType_Call {
	_c.Call.Return(_a0)
	return _c
}

func (_c *FeeConfig_LimitJobType_Call) RunAndReturn(run func() config.LimitJobType) *FeeConfig_LimitJobType_Call {
	_c.Call.Return(run)
	return _c
}

// PriceMaxKey provides a mock function with given fields: addr
func (_m *FeeConfig) PriceMaxKey(addr common.Address) *assets.Wei {
	ret := _m.Called(addr)

	if len(ret) == 0 {
		panic("no return value specified for PriceMaxKey")
	}

	var r0 *assets.Wei
	if rf, ok := ret.Get(0).(func(common.Address) *assets.Wei); ok {
		r0 = rf(addr)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*assets.Wei)
		}
	}

	return r0
}

// FeeConfig_PriceMaxKey_Call is a *mock.Call that shadows Run/Return methods with type explicit version for method 'PriceMaxKey'
type FeeConfig_PriceMaxKey_Call struct {
	*mock.Call
}

// PriceMaxKey is a helper method to define mock.On call
//   - addr common.Address
func (_e *FeeConfig_Expecter) PriceMaxKey(addr interface{}) *FeeConfig_PriceMaxKey_Call {
	return &FeeConfig_PriceMaxKey_Call{Call: _e.mock.On("PriceMaxKey", addr)}
}

func (_c *FeeConfig_PriceMaxKey_Call) Run(run func(addr common.Address)) *FeeConfig_PriceMaxKey_Call {
	_c.Call.Run(func(args mock.Arguments) {
		run(args[0].(common.Address))
	})
	return _c
}

func (_c *FeeConfig_PriceMaxKey_Call) Return(_a0 *assets.Wei) *FeeConfig_PriceMaxKey_Call {
	_c.Call.Return(_a0)
	return _c
}

func (_c *FeeConfig_PriceMaxKey_Call) RunAndReturn(run func(common.Address) *assets.Wei) *FeeConfig_PriceMaxKey_Call {
	_c.Call.Return(run)
	return _c
}

// NewFeeConfig creates a new instance of FeeConfig. It also registers a testing interface on the mock and a cleanup function to assert the mocks expectations.
// The first argument is typically a *testing.T value.
func NewFeeConfig(t interface {
	mock.TestingT
	Cleanup(func())
}) *FeeConfig {
	mock := &FeeConfig{}
	mock.Mock.Test(t)

	t.Cleanup(func() { mock.AssertExpectations(t) })

	return mock
}
